#!/usr/bin/env bash

set -eou pipefail

if [ $# -ne 2 ]
then
	echo "usage: $0 <workflow_name> <resource_name>"
	exit 1
fi

resource_name=$1
workflow_name=$2

while read -r CMD_LINE
do
	$CMD_LINE
done < "reset_cmds-$resource_name-$workflow_name.tmp"

