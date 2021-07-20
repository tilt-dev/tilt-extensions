#!/usr/bin/env bash 

set -eou pipefail

./increment_index.sh
./exec_workflow.sh
