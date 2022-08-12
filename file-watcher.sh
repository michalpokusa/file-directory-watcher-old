#!/bin/bash
WATCHED_NAME=$1
TIME_BETWEEN_WATCHES=$2
shift 2
COMMAND_TO_RUN=$@

# If empty string or does not exist
if [[ (-z "$WATCHED_NAME") || (! -e $WATCHED_NAME) ]]
then
    echo "No file/directory provider or does not exist..."
    exit 0
else
    if [[ -f $WATCHED_NAME ]]
    then
        TYPE="file"
    fi
    if [[ -d $WATCHED_NAME ]]
    then
        TYPE="directory"
    fi

    echo "Watching $TYPE $WATCHED_NAME..."
fi

LAST_TIME_MODIFIED="$(ls -laR $WATCHED_NAME | md5sum)"

while true; do
    if [[ ! -e $WATCHED_NAME ]]
    then
        echo "${TYPE^} does not exist"
        exit 0
    fi
    sleep $TIME_BETWEEN_WATCHES
    CURRENT_LAST_TIME_MODIFIED="$(ls -laR $WATCHED_NAME | md5sum)"

    if [[ $LAST_TIME_MODIFIED != $CURRENT_LAST_TIME_MODIFIED ]]
    then
        LAST_TIME_MODIFIED="$CURRENT_LAST_TIME_MODIFIED"

        CURRENT_TIME=$(date +'%Y-%m-%d %H:%M:%S')

        echo "[$CURRENT_TIME] ${TYPE^} $WATCHED_NAME changed: $COMMAND_TO_RUN"
        eval $COMMAND_TO_RUN
        echo "[$CURRENT_TIME] Back to watching ${TYPE^} $WATCHED_NAME"
    fi
done
