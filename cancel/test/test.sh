#!/bin/bash

cd "$(dirname "$0")" || exit

set -uxo pipefail
tilt ci > tilt.log &

sleep 1
timeout 30 tail -f tilt.log | grep -q "uibutton.tilt.dev/sleep:update:cancel created"
timeout 30 tail -f tilt.log | grep -q "cmd.tilt.dev/sleep:update:cancel created"

# Hit the cancel button. This should make tilt exit.
./trigger.sh

# Wait for the asynchronous button event to run the cancellation command.
RESULT=1
for _ in {1..300}; do
  if grep -q "Running cmd: ./kill_cmd.sh sleep:update" tilt.log; then
    RESULT=0
    break
  fi
  sleep 0.1
done

cat tilt.log
rm tilt.log

tilt down
exit $RESULT

