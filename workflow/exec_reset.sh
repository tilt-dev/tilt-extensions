#!/usr/bin/env bash

cat reset_cmds.tmp | while read CMD_LINE
do
	echo "executing command: '$CMD_LINE'"
	$CMD_LINE
done

