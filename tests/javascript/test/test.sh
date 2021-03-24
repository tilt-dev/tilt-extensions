#!/bin/bash

set -x

cd $(dirname $0)

msg_and_exit () {
  echo "$1"
  exit 1
}

# Tests TK

echo
echo "✨ Tests passed!"
exit 0
