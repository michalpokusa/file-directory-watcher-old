#!/bin/bash
{

# Default values
interval=10
command="echo Detected change"

# Function that displays the help
displayHelp() {
    echo "Usage: fdw.sh [options...] [files or folders to watch...]"
    echo "Watch files or/and directories and execute a command when they change."
    echo ""
    echo "-i, --interval:               Interval between watches"
    echo "-b, --background:             Run command in background"
    echo "-c, --command:                Command to execute"
    echo "-u, --update:                 Update script from GitHub repository"
    echo "-h, --help:                   Show this help"
}

# If no arguments are specified, display the help, then exit
if [[ $# -eq 0 ]]; then
    displayHelp
    exit 0
fi

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

    # Update script from GitHub repository
    -u|--update)
        curl https://raw.githubusercontent.com/michalpokusa/file-directory-watcher/main/fdw.sh > $0
        exit 0
    ;;

    # Show this help
    -h|--help)
        displayHelp
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
        shift 1
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
    echo $(ls -lu --almost-all --recursive --full-time $@ 2>/dev/null)
}


echo "[$(currentTime)] Watching ${watched_files_and_folders[@]} every ${interval}s..."

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
}
