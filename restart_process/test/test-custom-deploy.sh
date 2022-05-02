#!/bin/bash

# make sure that docker_build_with_restart works with k8s_custom_deploy
# https://github.com/tilt-dev/tilt-extensions/issues/391

cd "$(dirname "$0")" || exit

set -x
tilt down -f custom_deploy.Tiltfile

tilt up -f custom_deploy.Tiltfile --stream > tilt.log &
TILT_PID=$!

sleep 1
timeout 30 tail -f tilt.log  | grep -q "test_update │ restart detected"
RESULT=$?
cat tilt.log

kill $TILT_PID
tilt down
rm tilt.log

exit $RESULT
