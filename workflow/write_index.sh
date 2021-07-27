#!/usr/bin/env bash 

set -eou pipefail

if [ $# -ne 3 ]
then
	echo "usage: $0 <workflow_name> <resource_name> <index>"
	exit 1
fi 

resource_name=$1
workflow_name=$2
index=$3

indexfile="workflow_index-$resource_name-$workflow_name.tmp"

echo "$index" > "$indexfile"

