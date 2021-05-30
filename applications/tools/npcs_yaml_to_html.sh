#!/bin/sh

RUN_DIR=`dirname $0`

CONTENT_DIR="$RUN_DIR/../../../content"
NPCS_DIR="$CONTENT_DIR/npcs"
HTML_OUTPUT_DIR="$NPCS_DIR/html"
HTML_NPC_TEMPLATE="$HTML_OUTPUT_DIR/npc_template.html"

#
# First validate all the YAML files.
#
"$RUN_DIR/validate_yaml.sh" $NPCS_DIR/*.yaml \
    || exit 1

#
# OK, now we can convert them all into HTML.
#
"$RUN_DIR/yaml_to_html.sh" "$HTML_NPC_TEMPLATE" $NPCS_DIR/*.yaml \
    || exit 2

echo ""
echo "SUCCESS converting NPCs from YAML to HTML: $HTML_OUTPUT_DIR"
echo ""

exit 0
