#!/bin/sh

if test $# -lt 2
then
    echo "Usage: $0 (html-template-filename) (yaml-filename)..."
    echo ""
    echo "Converts 1 or more YAML NPC files to HTML."
    exit 1
fi

HTML_TEMPLATE_FILE=$1
shift
YAML_FILES=$*

RUN_DIR=`dirname $0`

if test ! -f "$HTML_TEMPLATE_FILE"
then
    echo "ERROR No such HTML template file: $HTML_TEMPLATE_FILE"
    exit 2
fi

TEMP_YAML_TO_HTML_FILE=$RUN_DIR/_temp_yaml_to_html.$$.sh
for YAML_FILE in $YAML_FILES
do
    if test ! -f "$YAML_FILE"
    then
        echo "ERROR No such YAML file: $YAML_FILE"
        exit 3
    fi

    HTML_OUTPUT_DIR=`echo "$YAML_FILE" \
                         | sed 's|/\([^/]*\)$|/html|'`
    HTML_OUTPUT_FILE_BASE=`echo "$YAML_FILE" \
                               | sed 's|^.*/\([^/]*\)\.yaml$|\1.html|'`
    HTML_OUTPUT_FILE="$HTML_OUTPUT_DIR/$HTML_OUTPUT_FILE_BASE"

    echo "#!/bin/sh" \
         > "$TEMP_YAML_TO_HTML_FILE" \
        || exit 4
    echo "echo \"Creating $HTML_OUTPUT_FILE ...\"" \
         >> "$TEMP_YAML_TO_HTML_FILE" \
        || exit 5
    echo "mkdir -p \"$HTML_OUTPUT_DIR\" || exit 1" \
         >> "$TEMP_YAML_TO_HTML_FILE" \
        || exit 6
    echo "echo \"\" | pandoc --standalone --template \"$HTML_TEMPLATE_FILE\" \\" \
         >> "$TEMP_YAML_TO_HTML_FILE" \
        || exit 7
    $RUN_DIR/yaml_to_path.sh "$YAML_FILE" \
        | sed 's|\\|\\\\"|g' \
        | sed 's|"|\\"|g' \
        | awk '
               BEGIN {
                   FS = "=";
               }
               {
                   gsub(/[^a-zA-Z0-9]/, ".", $1);
                   gsub(/---*/, "-", $1);
                   gsub(/-$/, "", $1);
                   print "    --metadata \"" $1 ":" $2 "\" \\";
               }
              ' \
        >> "$TEMP_YAML_TO_HTML_FILE" \
        || exit 8
    echo "    --metadata \"title:!!!TEST\" \\" \
         >> "$TEMP_YAML_TO_HTML_FILE" \
        || exit 9
    echo "    > $HTML_OUTPUT_FILE" \
         >> "$TEMP_YAML_TO_HTML_FILE" \
        || exit 10

    chmod a+x "$TEMP_YAML_TO_HTML_FILE" \
        || exit 11

    "$TEMP_YAML_TO_HTML_FILE" \
        || exit 12

    if test ! -f "$HTML_OUTPUT_FILE"
    then
        echo "ERROR Failed to create $HTML_OUTPUT_FILE from $YAML_FILE: $TEMP_YAML_TO_HTML_FILE"
        exit 13
    fi

    # !!! rm -f "$TEMP_YAML_TO_HTML_FILE" \
    # !!!     || exit 14
done

echo "SUCCESS Converting YAML files to HTML."
exit 0
