#!/bin/bash

# find all scripts named 'test.sh' and run them
# fail immediately if any fail

cd "$(dirname "$0")"

set -euo pipefail

SKIPPED_TESTS=(
# TODO(milas): the prometheus resources need more CPU than
#   our CI KIND cluster can provide
coreos_prometheus/test/test.sh
# TODO(nick): Currently it's a PITA to run podman in CI,
# so we've turned this off. You can still run it manually
# on a machine with podman installed.
#
podman/test/test.sh

# TODO(nick): Get nix working inside circleci
nix/test/test.sh
)

isSkipped() {
  local TEST="$1"
  for SKIPPED_TEST in "${SKIPPED_TESTS[@]}"; do
    if [ "$SKIPPED_TEST" = "$TEST" ]; then
      return 0
    fi
  done
  return 1
}

while IFS= read -r -d '' TEST
do
  # don't re-execute itself
  if [ "$TEST" == "test.sh" ]; then
    continue
  fi

  if ! isSkipped "$TEST"; then
    echo "running $TEST"
    $TEST
  else
    echo "skipping $TEST"
  fi
# `git ls-files` instead of `find` to ensure we skip stuff like .git and ./git_resource/test/.git-sources
done < <(git ls-files -z "**/test.sh")
