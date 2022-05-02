#!/bin/sh
set -euo pipefail
RESTART_COUNT="$(cat restart_count.txt)"
echo "RESTART_COUNT: $RESTART_COUNT"
RESTART_COUNT=$((RESTART_COUNT+1))
echo $RESTART_COUNT > restart_count.txt
while true
do
  echo running
  sleep 5
done
