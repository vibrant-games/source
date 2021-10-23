#!/bin/sh

LOG_FILE=20211019_repeatedly_publish.log

echo "======================================================" \
    | tee --append "$LOG_FILE"
date \
    | tee --append "$LOG_FILE"

echo "STARTING PUBLISHING" \
    | tee --append "$LOG_FILE"

while test 1 -eq 1
do
    echo "Publishing" \
        | tee --append "$LOG_FILE"

    ./publish_www.sh \
        2>&1 \
        | tee --append "$LOG_FILE" \
        || echo "ERROR PUBLISHING" >> "$LOG_FILE"

    echo "Sleeping for 10 minutes" \
        | tee --append "$LOG_FILE"

    sleep 600
done

echo "DONE" \
    | tee --append "$LOG_FILE"

exit 0
