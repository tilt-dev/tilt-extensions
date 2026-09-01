#!/bin/bash

cd "$(dirname "$0")" || exit

set -euo pipefail

expect() {
  if ! (echo "$1" | grep -q "$2"); then
    echo "did not find '$2' in output:"
    echo
    echo "$1"
    exit 1
  fi
}

echo "--- OUTSIDE A WORKTREE ZERO RUNTIME (defaults) ---"
OUTPUT="$(env -u WT0_SLOT -u WT0_PORT_BASE -u WT0_RUNTIME_ID -u WT0_BRANCH \
  -u COMPOSE_PROJECT_NAME tilt ci)"
expect "$OUTPUT" 'slot=0'
expect "$OUTPUT" 'port=20007'
expect "$OUTPUT" 'runtime=wt0-local'
expect "$OUTPUT" 'short=wt0-loca'
expect "$OUTPUT" 'ns=wt0-wt0-loca'
expect "$OUTPUT" 'compose=wt0-wt0-loca'
expect "$OUTPUT" 'shared=wt0-shared'
expect "$OUTPUT" 'resource=appdb_wt0-loca'
expect "$OUTPUT" 'slotresource=appdb_wt0_0'
echo "PASS"

echo "--- INSIDE A WORKTREE ZERO RUNTIME (WT0_* exported by wt0 run) ---"
OUTPUT="$(WT0_SLOT=3 WT0_PORT_BASE=23400 \
  WT0_RUNTIME_ID=0198f3a2-9d2c-7e11-a5f0-1234567890ab \
  COMPOSE_PROJECT_NAME=wt0-0198f3a2 tilt ci)"
expect "$OUTPUT" 'slot=3'
expect "$OUTPUT" 'port=23407'
expect "$OUTPUT" 'short=0198f3a2'
expect "$OUTPUT" 'ns=wt0-0198f3a2'
expect "$OUTPUT" 'compose=wt0-0198f3a2'
expect "$OUTPUT" 'resource=appdb_0198f3a2'
expect "$OUTPUT" 'slotresource=appdb_wt0_3'
echo "PASS"
