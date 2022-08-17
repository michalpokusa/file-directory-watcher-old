#!/bin/bash

# Default values
interval=10
command="echo Detected change"

# Parsing command line arguments
watched_files_and_folders=()
while [[ $# -gt 0 ]]; do
    case $1 in

    # Interval between watches
    -i|--interval)
        interval=$2
        shift 2
    ;;
    -i=*|--interval=*)
        interval=${1#*=}
        shift
    ;;

    # Run command in background
    -b|--background)
        background=true
        shift 1
    ;;

    # Command to execute
    -c|--command)
        command=$2
        shift 2
    ;;
    -c=*|--command=*)
        command=${1#*=}
        shift
    ;;

    # Show this help
    -h|--help)
    echo "Usage: file-watcher.sh [options...] [files or folders to watch...]"
    echo "Watch files or/and directories and execute a command when they change."
    echo ""
    echo "-i, --interval:               Interval between watches"
    echo "-b, --background:             Run command in background"
    echo "-c, --command:                Command to execute"
    echo "-h, --help:                   Show this help"
    exit 0
    ;;

    # Unknown option
    -*|--*)
        echo Unknown option $1
        exit 1
    ;;

    # File or directory to watch
    *)
        watched_files_and_folders+=("$1")
        shift
    ;;
    esac
done
set -- "${watched_files_and_folders[@]}"


# Function that returns the current time in pre-defined format
currentTime() {
    echo $(date +'%Y-%m-%d %H:%M:%S.%N%:z')
}

# Function that returns the current state of the watched files and directories
currentDirectoryState() {
    echo $(ls -lu --almost-all --recursive --full-time $@)
}


echo "[$(currentTime)] Watching ${watched_files_and_folders[@]}..."

last_time_state="$(currentDirectoryState ${watched_files_and_folders[@]})"

while sleep $interval; do

    current_state="$(currentDirectoryState ${watched_files_and_folders[@]})"

    # Checking if the state of the file/directory has changed
    if ([[ $last_time_state != $current_state ]] )
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
