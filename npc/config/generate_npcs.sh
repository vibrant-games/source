#!/bin/sh

#
# Generates a JavaScript index of NPCs.
#
# For now, file: URLs are generated.
#
# In future, http: or https: URLs will be generated,
# so that the NPC HTML can be dynamically created by
# other webservers.
#
if test $# -ne 1
then
    echo ""
    echo "Usage: $0 (content-dir)" >&2
    echo "" >&2
    echo "Generates npcs.js, a JavaScript index of NPC HTML pages." >&2
    echo "" >&2
    echo "(content-dir): The full path to the root of the 'content' git" >&2
    echo "               repository.  This directory contains npcs/html/." >&2
    echo "               Example: ../../../../../foo/bar/content" >&2
    echo "" >&2
    exit 1
fi

CONTENT_REPO_DIR=$1

RUN_DIR=`dirname $0`
TOOLS_DIR="$RUN_DIR/../../applications/tools"

NPCS_YAML_DIR="$CONTENT_REPO_DIR/npcs"
NPCS_HTML_DIR="$CONTENT_REPO_DIR/npcs/html"

NPCS_JS="$RUN_DIR/npcs.js"

if test ! -d "$NPCS_YAML_DIR"
then
    echo "ERROR Cannot access npcs-yaml-dir: $NPCS_YAML_DIR" >&2
    exit 2
fi

if test ! -d "$NPCS_HTML_DIR"
then
    echo "ERROR Cannot access npcs-html-dir: $NPCS_HTML_DIR" >&2
    exit 2
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    || exit 3

DASEL=`which dasel`
if test $? -ne 0 \
	-o "$DASEL" = ""
then
    echo "ERROR dasel must be installed to use $0: brew install dasel (https://daseldocs.tomwright.me/installation)"
    exit 1
fi

echo "Creating $NPCS_JS..."
rm -f "$NPCS_JS"
echo "const npcs = {};" > "$NPCS_JS" \
    || exit 1

NUM_NPCS=0
for NPC_YAML_FILE in $NPCS_YAML_DIR/*.yaml
do
    NPC_ID=`dasel select --file "$NPC_YAML_FILE" --read yaml --plain --selector metadata.id \
                2> /dev/null`
    DASEL_EXIT_CODE=$?
    if test $DASEL_EXIT_CODE -ne 0
    then
        echo "ERROR retrieving NPC id from $NPC_YAML_FILE: $NPC_ID"
        exit 1
    fi

    NPC_NAME=`dasel select --file "$NPC_YAML_FILE" --read yaml --plain --selector npc.name \
                2> /dev/null`
    DASEL_EXIT_CODE=$?
    if test $DASEL_EXIT_CODE -ne 0
    then
        echo "ERROR retrieving NPC name from $NPC_YAML_FILE: $NPC_NAME"
        exit 1
    fi

    NPC_YAML_BASE_FILENAME=`basename "$NPC_YAML_FILE"`
    NPC_HTML_BASE_FILENAME=`echo "$NPC_YAML_BASE_FILENAME" \
                                | sed 's|\.yaml$|.html|'`
    NPC_HTML_FILE="$NPCS_HTML_DIR/$NPC_HTML_BASE_FILENAME"

    NPC_NAME_SCRUBBED=`$TOOLS_DIR/json_scrub.sh "$NPC_NAME"`

    echo "npcs.$NPC_ID = {" >> "$NPCS_JS" \
	|| exit 1
    echo "    \"id\": \"$NPC_ID\"," >> "$NPCS_JS" \
	|| exit 1
    echo "    \"name\": \"$NPC_NAME_SCRUBBED\"," >> "$NPCS_JS" \
	|| exit 1
    echo "    \"html_url\": \"file:///var/npcs/html/$NPC_HTML_BASE_FILENAME\"," >> "$NPCS_JS" \
	|| exit 1
    echo "    \"yaml_url\": \"file:///var/npcs/$NPC_YAML_BASE_FILENAME\"," >> "$NPCS_JS" \
	|| exit 1
    echo "    };" >> "$NPCS_JS" \
	|| exit 1

    NEW_NUM_NPCS=`expr $NUM_NPCS + 1`
    NUM_NPCS=$NEW_NUM_NPCS
done

echo "module.exports = { npcs };" >> "$NPCS_JS" \
    || exit 1

echo "SUCCESS creating $NPCS_JS with $NUM_NPCS NPCs."

exit 0
