#!/usr/bin/env bash

set -eou pipefail

if [ $# -le 2 ]
then
	echo "usage: $0 <workflow_name> <resource_name> cmd1 [cmd2...]"
	exit 1
fi

resource_name=$1
workflow_name=$2

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
state_dir="${TILT_WORKFLOW_STATE_PATH:-$script_dir}"

cmdfile="${state_dir}/workflow_cmds-$resource_name-$workflow_name.tmp"

rm -f "$cmdfile"
shift 2
for i in "$@"
do
	echo "$i" >> "$cmdfile"
done
