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
expect "$OUTPUT" 'short=wt0-local'
expect "$OUTPUT" 'ns=wt0-wt0-local'
expect "$OUTPUT" 'compose=wt0-wt0-local'
expect "$OUTPUT" 'shared=wt0-shared'
expect "$OUTPUT" 'resource=appdb_wt0-local'
expect "$OUTPUT" 'slotresource=appdb_wt0_0'
echo "PASS"

echo "--- INSIDE A WORKTREE ZERO RUNTIME (WT0_* exported by wt0 run) ---"
OUTPUT="$(WT0_SLOT=3 WT0_PORT_BASE=23400 \
  WT0_RUNTIME_ID=0198f3a2-9d2c-7e11-a5f0-1234567890ab \
  COMPOSE_PROJECT_NAME=wt0-1234567890ab tilt ci)"
expect "$OUTPUT" 'slot=3'
expect "$OUTPUT" 'port=23407'
expect "$OUTPUT" 'short=1234567890ab'
expect "$OUTPUT" 'ns=wt0-1234567890ab'
expect "$OUTPUT" 'compose=wt0-1234567890ab'
expect "$OUTPUT" 'resource=appdb_1234567890ab'
expect "$OUTPUT" 'slotresource=appdb_wt0_3'
echo "PASS"

echo "--- CONCURRENT UUIDV7 RUNTIMES WITH THE SAME TIMESTAMP PREFIX ---"
OUTPUT_ONE="$(WT0_SLOT=4 WT0_PORT_BASE=23500 \
  WT0_RUNTIME_ID=0198f3a2-9d2c-7e11-a5f0-aaaaaaaaaaaa tilt ci)"
OUTPUT_TWO="$(WT0_SLOT=5 WT0_PORT_BASE=23600 \
  WT0_RUNTIME_ID=0198f3a2-9d2c-7e11-a5f0-bbbbbbbbbbbb tilt ci)"
expect "$OUTPUT_ONE" 'short=aaaaaaaaaaaa'
expect "$OUTPUT_ONE" 'ns=wt0-aaaaaaaaaaaa'
expect "$OUTPUT_ONE" 'compose=wt0-aaaaaaaaaaaa'
expect "$OUTPUT_TWO" 'short=bbbbbbbbbbbb'
expect "$OUTPUT_TWO" 'ns=wt0-bbbbbbbbbbbb'
expect "$OUTPUT_TWO" 'compose=wt0-bbbbbbbbbbbb'
echo "PASS"
