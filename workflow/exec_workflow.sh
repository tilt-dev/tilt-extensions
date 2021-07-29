#!/usr/bin/env bash

set -eou pipefail

if [ $# -ne 2 ]
then
	echo "usage: $0 <workflow_name> <resource_name>"
	exit 1
fi

resource_name=$1
workflow_name=$2

indexfile="workflow_index-$resource_name-$workflow_name.tmp"
cmdsfile="workflow_cmds-$resource_name-$workflow_name.tmp"

WORKFLOW_INDEX=$(head -n 1 <"$indexfile")

if [[ "$WORKFLOW_INDEX" -eq "0" ]] ; then
	echo "no step to replay"
	exit 0
fi

$(head -n "$WORKFLOW_INDEX" "$cmdsfile" | tail -n 1)

