#!/usr/bin/env bash

for l in reset_cmds.tmp
do
	echo "executing command: '$l'"
	$l
done

