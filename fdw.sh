#!/bin/bash
{

# Default values
interval=10
command="echo Detected change"
filesAndFolders=( "." )

# Function that displays the help
displayHelp() {
    echo "Usage: fdw.sh [options...]"
    echo "Watch files or/and directories and execute a command when they change."
    echo ""
    echo "-i, --interval:               Interval between watches"
    echo "-b, --background:             Run command in background"
    echo "-c, --command:                Command to execute"
    echo "-f, --file"
    echo "-d, --directory:              Files or directories to watch, stop with --"
    echo "-h, --help:                   Show this help"
}

# If no arguments are specified, display the help, then exit
if [[ $# -eq 0 ]]; then
    displayHelp
    exit 0
fi

# Parsing command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in

    # Interval between watches
    -i|--interval)
        interval=$2
        shift 2
    ;;
    -i=*|--interval=*)
        interval=${1#*=}
        shift 1
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
        shift 1
    ;;

    # Files or directories to watch
    -f|--file|-d|--directory)
        shift 1
        filesAndFolders=()
        for fileOrFolder in "$@"; do
            shift 1
            if [[ "$fileOrFolder" == "--" ]]; then
                break
            fi
            filesAndFolders+=( "$fileOrFolder" )
        done
    ;;

    # Show this help
    -h|--help)
        displayHelp
        exit 0
    ;;

    # Unknown option
    -*|--*|*)
        echo Unknown option $1
        exit 1
    ;;
    esac
done


# Function that returns the current time in pre-defined format
currentTime() {
    echo $(date +'%Y-%m-%d %H:%M:%S')
}

# Function that returns the current state of the watched files and directories
currentDirectoryState() {
    echo $(ls -lu --almost-all --recursive --full-time "${filesAndFolders[@]}" 2>/dev/null)
}

verboseFilesAndFolders() {
    output=""
    for name in "${filesAndFolders[@]}"; do
        output+="\"$name\", "
    done
    echo "${output::-2}"
}


echo "[$(currentTime)] Watching $(verboseFilesAndFolders) every ${interval}s, on change running: $command"

lastTimeState="$(currentDirectoryState)"

while sleep $interval; do

    currentState="$(currentDirectoryState)"

    # Checking if the state of the file/directory has changed
    if ([[ $lastTimeState != $currentState ]] )
    then
        lastTimeState="$currentState"

        # Executing the command in background if specified, otherwise executing it in foreground
        if [[ $background ]]
        then
            echo "[$(currentTime)] Running in background: $command"
            eval $command &
        else
            echo "[$(currentTime)] Running in foreground: $command"
            eval $command
        fi

        echo "[$(currentTime)] Back to watching $(verboseFilesAndFolders)"
    fi
done
}
