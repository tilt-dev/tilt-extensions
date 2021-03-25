#!/bin/bash

set -x

cd $(dirname $0)

msg_and_exit () {
  echo "$1"
  exit 1
}

echo "=== Test Single Package"
tilt ci single-package || msg_and_exit "Expected 'tilt ci' to succeed, but exited with code $?"

echo
echo "=== Test Recursive"
tilt ci recursive && msg_and_exit "Expected 'tilt ci' to fail, but succeeded."

echo
echo "=== Test Tags"
tilt ci tags || msg_and_exit "Expecteed 'tilt ci' to succed, but exited with code $?"

echo
echo "=== Test Timeout"
tilt ci timeout && msg_and_exit "Expected 'tilt ci' to fail, but succeeded."

echo
echo "=== Test Bad Timeout Value"
tilt ci bad-timeout-value && msg_and_exit "Expected 'tilt ci' to fail, but succeeded."

echo
echo "✨ Tests passed!"
exit 0
