#!/bin/sh

if test $# -eq 0
then
    echo "Usage: $0 (yaml-input-file-path) ..."
    echo ""
    echo "Splits the specified YAML file into multiple files under the same"
    echo "parent path."
    echo ""
    echo "The monolith file is split by '---' dpcument dividers."
    echo ""
    echo "The split files are each named by the 'id' attribute in each"
    echo "document.  If there is none, then the process will fail wiuthout"
    echo "creating any new files at all."
    echo ""
    exit 1
fi

FILENAME_FIELD="id"
FILENAME_PRE=""
FILENAME_POST=".yaml"

#
# First check splittability of the monolithic YAML file:
#
for YAML_INPUT_FILE in $*
do
    OUTPUT_DIR=`dirname "$YAML_INPUT_FILE"`
    if test -z "$OUTPUT_DIR"
    then
        echo "ERROR Failed to determine parent path for YAML input file $YAML_INPUT_FILE"
        exit 2
    fi

    cat "$YAML_INPUT_FILE" \
        | sed 's|[\r]||g' \
        | awk \
              -v "input_path=$YAML_INPUT_FILE" \
              -v "output_dir=$OUTPUT_DIR" \
              -v "filename_field=$FILENAME_FIELD" \
              -v "filename_pre=$FILENAME_PRE" \
              -v "filename_post=$FILENAME_POST" \
              '
               BEGIN {
                   line_num_divider = -1;
                   line_num_start = -1;
                   yaml_output_filename = "";
                   yaml_output_path = "";
                   is_error = "false";
                   line_num = 0;
               }

               {
                   line_num ++;
                   line_type = "none";
               }

               $0 == "---" {
                   if ( line_num_start > 0 && yaml_output_path == "" ) {
                       line_end = line_num - 1;
                       print "ERROR document lines " line_num_start " - " line_end " do not contain a(n) " filename_field " field: " input_path;
                       is_error = "true";

                   }

                   line_num_divider = line_num;
                   line_num_start = -1;
                   yaml_output_filename = "";
                   yaml_output_path = "";
                   line_type = "divider";
               }

               $0 ~ /^[ ]*#.*$/ {
                   line_type = "comment";
               }

               $0 ~ /^[ ]*$/ {
                   line_type = "blank";
               }

               line_type == "none" {
                   line_type = "yaml";
               }

               line_type == "yaml" && line_num_start <= 0 {
                   line_num_start = line_num_divider + 1;
               }

               line_type == "yaml" && $1 == filename_field ":" {
                   if ( NF < 2 ) {
                       print "ERROR document " filename_field " field at line " line_num " has no value: " input_path;
                       is_error = "true";
                   }
                   else if ( NF > 2 ) {
                       print "ERROR document " filename_field " field at line " line_num " contains spaces (" $0 "): " input_path;
                       is_error = "true";
                   }
                   else if ( yaml_output_path != "" ) {
                       print "ERROR document starting at line " line_num_start " (" yaml_output_filename ") has 2nd " filename_field " field at line " line_num " (" $0 "): " input_path;
                       is_error = "true";
                   }

                   yaml_output_filename = filename_pre $2 filename_post;
                   yaml_output_path = output_dir "/" yaml_output_filename;
               }

               END {
                   if ( line_num_start > 0 && yaml_output_path == "" ) {
                       line_end = line_num;
                       print "ERROR document lines " line_num_start " - " line_end " do not contain a(n) " filename_field " field: " input_path;
                       is_error = "true";
                   }

                   if ( "is_error" == "true" ) {
                       exit 3;
                   }
               }
              '
done
