#!/bin/bash

# Check if no arguments are passed to the script
if [ "$#" -eq 0 ]; then
    # Check if the sleep process is running
    pidof sleep > /dev/null || {
        # If sleep is not running, start it in interactive mode without creating a new process group
        exec sleep infinity
    }
fi

# Default to run whatever the user wanted, e.g. "sh"
exec "$@"
