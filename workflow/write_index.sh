#!/usr/bin/env bash 

if [ "$#" -ne 1 ]; then
	echo "usage: $0 <index>"
	exit 1
fi

echo "$1" > workflow_index.tmp

echo "file workflow_index.tmp now contains:"
cat workflow_index.tmp

