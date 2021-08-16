#!/bin/bash

cd "$(dirname "$0")" || exit

set -uxo pipefail
tilt ci > tilt.log &
TILT_PID=$!

sleep 1
timeout 30 tail -f tilt.log | grep -q "uibutton.tilt.dev/sleep:update:cancel created"
timeout 30 tail -f tilt.log | grep -q "cmd.tilt.dev/sleep:update:cancel created"

# Hit the cancel button. This should make tilt exit.
./trigger.sh

# Move tilt ci to the foreground, and ignore errors
timeout 15 fg

grep -q "Running cmd: ./kill_cmd.sh sleep:update" tilt.log
RESULT=$?

cat tilt.log
rm tilt.log

tilt down
exit $RESULT

