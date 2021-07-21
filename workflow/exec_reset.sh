#!/usr/bin/env bash

set -eou pipefail

if [ $# -ne 2 ]
then
	echo "usage: $0 <workflow_name> <resource_name>"
	exit 1
fi

resource_name=$1
workflow_name=$2

cat "reset_cmds-$resource_name-$workflow_name.tmp" | while read CMD_LINE
do
	# echo "executing command: '$CMD_LINE'"
	$CMD_LINE
done

