#!/bin/sh

if test $# -lt 1
then
    echo "Usage: $0 (text)..." >&2
    echo "" >&2
    echo "Scrubs dangerous characters out of text so it can be used" >&2
    echo "inside JSON \"\"." >&2
    echo "" >&2
    echo "Input:  $0 'Babita (\"Babs\")'" >&2
    echo "Output: Babita (\\\"Babs\\\")" >&2
    exit 1
fi

UNSCRUBBED_TEXT="$*"

SCRUBBED_TEXT=`echo "$UNSCRUBBED_TEXT" \
	           | sed 's|"|\\\\"|g'`
if test $? -ne 0 \
	-o -z "$SCRUBBED_TEXT"
then
    echo "ERROR scrubbing '$UNSCRUBBED_TEXT'" >&2
    exit 1
fi

echo "$SCRUBBED_TEXT"

exit 0
