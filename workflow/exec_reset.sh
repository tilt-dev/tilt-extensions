#!/usr/bin/env bash

set -eou pipefail

if [ $# -ne 2 ]
then
	echo "usage: $0 <workflow_name> <resource_name>"
	exit 1
fi

resource_name=$1
workflow_name=$2

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
state_dir="${TILT_WORKFLOW_STATE_PATH:-$script_dir}"

while read -r CMD_LINE
do
	$CMD_LINE
done < "${state_dir}/workflow_reset_cmds-$resource_name-$workflow_name.tmp"
