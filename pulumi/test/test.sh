#!/bin/bash

cd "$(dirname "$0")"

# Disable the pulumi test if no pulumi user.
# Circleci won't inject our pulumi secrets for PRs, but
# we still want to run other integration tests.
PULUMI_USER=$(pulumi whoami --non-interactive)
if [[ "$PULUMI_USER" == "" ]]; then
    echo "No pulumi user. Skipping pulumi test"
    exit 0
fi

set -ex

# install pulumi deps
yarn install

tilt ci
tilt down
