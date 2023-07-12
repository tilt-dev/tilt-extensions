#!/bin/bash

cd "$(dirname "$0")" || exit

set -euo pipefail

OUTPUT="$(tilt ci)"

if ! (echo "$OUTPUT" | grep -q foo); then
  echo "did not find string 'foo' in output"
  echo "output:"
  echo
  echo "$OUTPUT"
  exit 1
fi

if ! (echo "$OUTPUT" | grep -q bar); then
  echo "did not find string 'bar' in output"
  echo "output:"
  echo
  echo "$OUTPUT"
  exit 1
fi
