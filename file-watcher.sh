#!/bin/bash

if [[ -z "$1" ]]
then
    echo "No argument provided"
    exit 0
else
    if [[ ! -e $1 ]]
    then
        echo "File does not exist"
        exit 0
    else
        echo "Watching $1..."
    fi
fi

WATCHED_FILE_NAME=$1
shift 1

LAST_TIME_MODIFIED="$(stat -c %Y $WATCHED_FILE_NAME)"

while true; do
    if [[ ! -e $WATCHED_FILE_NAME ]]
    then
        echo "File does not exist"
        exit 0
    fi
    sleep 1
    CURRENT_LAST_TIME_MODIFIED="$(stat -c %Y $WATCHED_FILE_NAME)"
    if [[ $LAST_TIME_MODIFIED != $CURRENT_LAST_TIME_MODIFIED ]]
    then
        LAST_TIME_MODIFIED="$CURRENT_LAST_TIME_MODIFIED"

        CURRENT_TIME=$(date +'%Y-%m-%d %H:%M:%S')
        echo "[$CURRENT_TIME] File $WATCHED_FILE_NAME has changed"

        eval $@
    fi
done
