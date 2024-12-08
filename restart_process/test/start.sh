#!/bin/bash
# bash shebang required as we are using bash specific features: pipefail + trap

set -euo pipefail
RESTART_COUNT="$(cat restart_count.txt)"
echo "RESTART_COUNT: $RESTART_COUNT"
RESTART_COUNT=$((RESTART_COUNT+1))
echo $RESTART_COUNT > restart_count.txt

handle_sigterm() {
  echo "SIGTERM received"
  sleep 1
}

trap handle_sigterm SIGTERM

while true
do
  echo running
  sleep 5
done
