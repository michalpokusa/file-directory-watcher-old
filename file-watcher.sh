#!/bin/bash

# Parsing command line arguments
for option in "$@"
do
    case $option in

        # File or directory to watch
        -f=*|--file=*)
        type="file"
        watched_file_or_folder=${option#*=}
        ;;
        -d=*|--directory=*)
        type="directory"
        watched_file_or_folder=${option#*=}
        ;;

        # Interval between watches
        -i=*|--interval=*)
        interval=${option#*=}
        ;;

        # Run command in background
        -b|--background)
        background=true
        ;;

        # Command to execute
        -c=*|--command=*)
        command=${option#*=}
        ;;

        # Unknown option
        *)
        ;;
    esac
done


# Function that returns the current time in pre-defined format
currentTime() {
    echo $(date +'%Y-%m-%d %H:%M:%S.%N%:z')
}

# Function that returns the current state of the watched directory
currentDirectoryState() {
    echo $(ls -lu --almost-all --recursive --full-time $1)
}


# Exit if file or directory does not exist
if [[ (-z "$watched_file_or_folder") || (! -e $watched_file_or_folder) ]]
then
    echo "No file/directory provider or does not exist..."
    exit 0
fi

echo "Watching $type $watched_file_or_folder..."

last_time_state="$(currentDirectoryState $watched_file_or_folder)"

while sleep $interval; do

    # Exit if file or directory does not exist
    if [[ ! -e $watched_file_or_folder ]]
    then
        echo "${type^} $watched_file_or_folder does not exist"
        exit 0
    fi

    current_state="$(currentDirectoryState $watched_file_or_folder)"

    # Checking if the state of the file/directory has changed
    if ([[ $last_time_state != $current_state ]] && [[ -e $watched_file_or_folder ]])
    then
        last_time_state="$current_state"

        # Executing the command in background if specified, otherwise executing it in foreground
        if [[ $background ]]
        then
            echo "[$(currentTime)] Running in background: $command"
            eval $command &
        else
            echo "[$(currentTime)] Running in foreground: $command"
            eval $command
        fi

        echo "[$(currentTime)] Back to watching ${type^} $watched_file_or_folder"
    fi
done
