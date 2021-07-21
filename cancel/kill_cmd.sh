#!/bin/bash
#
# Usage:
# kill_cmd.sh CMD_NAME
#
# Kills the command with the given name.
#
# Passes any subsequent args to the kill command.
#
# Example:
# kill_cmd.sh my-cmd -9

set -euo pipefail

CMD_NAME="$1"
shift

PID=$(tilt get cmd "$CMD_NAME" -o "jsonpath={.status.running.pid}")
if [[ "$PID" == "" ]]; then
    echo "Cmd $CMD_NAME not running"
    exit 1
fi

kill "$PID" "$@"


