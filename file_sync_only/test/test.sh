#!/bin/bash

cd "$(dirname "$0")" || exit

set -x
tilt up --stream > tilt.log &
TILT_PID=$!

sleep 1
timeout 30 tail -f tilt.log  | grep -q "verify │ SUCCESS!"
RESULT=$?
cat tilt.log

kill $TILT_PID
tilt down
rm tilt.log

exit $RESULT
