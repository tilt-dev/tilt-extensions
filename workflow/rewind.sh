#!/usr/bin/env bash 

set -eou pipefail

./write_index.sh 0
./exec_reset.sh
