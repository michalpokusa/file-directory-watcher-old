#!/bin/bash

WATCHED_NAME=$1
TIME_BETWEEN_WATCHES=$2
BLOCKING=$3

shift 3

COMMAND_TO_RUN=$@

# Function that returns the current time in pre-defined format
currentTime() {
    echo $(date +'%Y-%m-%d %H:%M:%S.%N%:z')
}

# Function that returns the current state of the watched directory
currentDirectoryState() {
    echo $(ls -lu --almost-all --recursive --full-time $1 &2>/dev/null)
}


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

LAST_TIME_MODIFIED="$(currentDirectoryState $WATCHED_NAME)"

while true; do
    if [[ ! -e $WATCHED_NAME ]]
    then
        echo "${TYPE^} $WATCHED_NAME does not exist"
        exit 0
    fi
    sleep $TIME_BETWEEN_WATCHES
    CURRENT_LAST_TIME_MODIFIED="$(currentDirectoryState $WATCHED_NAME)"

    if ([[ $LAST_TIME_MODIFIED != $CURRENT_LAST_TIME_MODIFIED ]] && [[ -e $WATCHED_NAME ]])
    then
        LAST_TIME_MODIFIED="$CURRENT_LAST_TIME_MODIFIED"

        echo "[$(currentTime)] ${TYPE^} $WATCHED_NAME changed: $COMMAND_TO_RUN"

        if [[ $BLOCKING == "block" ]]
        then
            eval $COMMAND_TO_RUN
        else
            eval $COMMAND_TO_RUN &
        fi

        echo "[$(currentTime)] Back to watching ${TYPE^} $WATCHED_NAME"
    fi
done
