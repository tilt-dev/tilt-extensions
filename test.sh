#!/bin/bash

# find all scripts named 'test.sh' and run them
# fail immediately if any fail

cd "$(dirname "$0")" || exit 1
exec python3 ./test.py
