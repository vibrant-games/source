#!/bin/sh

if test $# -ne 1
then
    echo "Usage: $0 (content-repository)"
    echo ""
    echo "Converts the NPC YAML files into HTML."
    echo ""
    echo "(content-repository): The root of the Vibrant Games content repo."
    echo "    If (content-repository) is /foo/bar, then the NPC YAML files"
    echo "    are found in /foo/bar/npcs, and the HTML output files will"
    echo "    be written to /foo/bar/npcs/html."
    echo ""
    exit 1
fi

CONTENT_DIR=$1

RUN_DIR=`dirname $0`
RUN_DATE_TIME=`date '+%Y%m%d_%H%M%S'`

NPCS_DIR="$CONTENT_DIR/npcs"
HTML_OUTPUT_DIR="$NPCS_DIR/html"
HTML_NPC_TEMPLATE="$HTML_OUTPUT_DIR/npc_template.html"
HTML_ALL_NPCS_TEMPLATE="$HTML_OUTPUT_DIR/npcs_all_template.html"
HTML_ALL_NPCS_TEMPLATE_PRE="$HTML_OUTPUT_DIR/npcs_all_template_pre.html"
HTML_ALL_NPCS_TEMPLATE_POST="$HTML_OUTPUT_DIR/npcs_all_template_post.html"
HTML_ALL_NPCS_SUMMARY="$HTML_OUTPUT_DIR/npcs_all_summary.html"
PDFS_ZIP="$CONTENT_DIR/vibrant_games_npcs.$RUN_DATE_TIME.zip"

#
# First validate all the YAML files.
#
"$RUN_DIR/validate_yaml.sh" $NPCS_DIR/*.yaml \
    || exit 1

#
# Create the big giant summary HTML table.
#
cat "$HTML_ALL_NPCS_TEMPLATE_PRE" > "$HTML_ALL_NPCS_SUMMARY" \
    || exit 2
for NPC_YAML_FILE in $NPCS_DIR/*.yaml
do
    "$RUN_DIR/yaml_to_html.sh" "$HTML_ALL_NPCS_TEMPLATE" "$NPC_YAML_FILE" \
        || exit 3
    HTML_NPC_OUTPUT_FILE_BASE=`echo "$NPC_YAML_FILE" \
                                   | sed 's|^.*/\([^/]*\)\.yaml$|\1|'`
    HTML_NPC_OUTPUT_FILE="$HTML_OUTPUT_DIR/$HTML_NPC_OUTPUT_FILE_BASE.html"
    cat "$HTML_NPC_OUTPUT_FILE" >> "$HTML_ALL_NPCS_SUMMARY" \
        || exit 4
done
cat "$HTML_ALL_NPCS_TEMPLATE_POST" >> "$HTML_ALL_NPCS_SUMMARY" \
    || exit 5

#
# OK, now we can convert them all into HTML.
#
"$RUN_DIR/yaml_to_html.sh" "$HTML_NPC_TEMPLATE" $NPCS_DIR/*.yaml \
    || exit 6

#
# Bundle up the PDFs directory, if it exists, into a zip file.
#
if test -d "$NPCS_DIR/pdf"
then
    echo "Creating $PDFS_ZIP..."
    zip -r -b "$CONTENT_DIR" "$PDFS_ZIP" $NPCS_DIR/pdf/ $NPCS_DIR/html/*.html $NPCS_DIR/html/*.css \
        || exit exit 7
fi

echo ""
echo "SUCCESS converting NPCs from YAML to HTML: $HTML_OUTPUT_DIR"
echo ""

exit 0
