#!/bin/bash

cd "$(dirname "$0")" || exit 1

# Spinning up initial test deployment
tilt ci -f setup.Tiltfile

# Enable remove development
tilt up -f Tiltfile --stream > tilt.log &
TILT_PID=$!

sleep 1

echo "Verifying that the app has started"
timeout 30 tail -f tilt.log | grep -q "listening on port 8080"
RESULT=$?
if [[ $RESULT -ne 0 ]];then
  echo "ERROR: App failed to start"
  cat tilt.log
  exit "$RESULT"
fi

echo "Verifying remote development is using the correct image built from Dockerfile.dev"
timeout 30 tail -f tilt.log | grep -q "nodemon"
RESULT=$?
if [[ $RESULT -ne 0 ]];then
  echo "ERROR: nodemon isn't running. Might be using the wrong image"
  cat tilt.log
  exit $RESULT
fi

echo "Verifying that file sync is working"
touch ./app/test.js
timeout 30 tail -f tilt.log  | grep -q "1 File Changed: \[app/test.js\]"
RESULT=$?
if [[ $RESULT -ne 0 ]];then
  echo "ERROR: File sync doesn't work"
  cat tilt.log
  exit "$RESULT"
fi

echo "Verifying that port forwarding was enabled"
curl -f localhost:8080
RESULT=$?
if [[ $RESULT -ne 0 ]];then
  echo "ERROR: Port forwarding wasn't enabled"
  cat tilt.log
  exit "$RESULT"
fi

echo "Verifying that livenessProbe was removed"
RESULT=$(kubectl get deployment/example-nodejs -o yaml | grep -c "livenessProbe")
if [[ $RESULT -ne 0 ]];then
  echo "ERROR: livenessProbe wasn't removed"
  kubectl get deployment/example-nodejs -o yaml
  exit "$RESULT"
fi

echo "Verifying that readinessProbe was removed"
RESULT=$(kubectl get deployment/example-nodejs -o yaml | grep -c "readinessProbe")
if [[ $RESULT -ne 0 ]];then
  echo "ERROR: readinessProbe wasn't removed"
  kubectl get deployment/example-nodejs -o yaml
  exit "$RESULT"
fi

cat tilt.log
kill $TILT_PID
tilt down
rm tilt.log

