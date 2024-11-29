#!/bin/bash

set -u

# triggers a live update and waits for the tilt logs to reflect the process was restarted
# exits 0 if it's successfully restarted, or 1 if not

touch start.sh
# seconds
TIMEOUT=10
for ((i=0;i<=TIMEOUT;++i)) do
  if tilt logs | grep -v test_update | grep -q "RESTART_COUNT: 1"; then
    echo restart detected
    exit 0
  fi
  echo no restart detected
  touch start.sh
  sleep 1
done
exit 1
