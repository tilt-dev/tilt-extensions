#!/usr/bin/env bash 

num_cmds=$(wc -l workflow_cmds.tmp | cut -f 8 -d ' ')
i=$(cat workflow_index.tmp)
i=$((i+1))
if [ "$i" -gt "$num_cmds" ] ; then
	i=1
fi

echo "$i" > workflow_index.tmp

