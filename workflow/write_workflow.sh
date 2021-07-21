#!/usr/bin/env bash

rm -f workflow_cmds.tmp
for i in "$@"
do
	echo "$i" >> workflow_cmds.tmp
done

echo "file workflow_cmds.tmp now contains:"
cat workflow_cmds.tmp

