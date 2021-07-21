#!/usr/bin/env bash

rm -f reset_cmds.tmp
for i in "$@"
do
	echo "$i" >> reset_cmds.tmp
done

echo "file reset_cmds.tmp now contains:"
cat reset_cmds.tmp

