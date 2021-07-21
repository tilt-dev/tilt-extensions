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

num_cmds=$(wc -l $cmdsfile | cut -f 8 -d ' ')
i=$(cat $indexfile)
i=$((i+1))
if [ "$i" -gt "$num_cmds" ] ; then
	i=1
fi

echo "$i" > $indexfile

