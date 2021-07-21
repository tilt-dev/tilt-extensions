#!/usr/bin/env bash

set -eou pipefail

if [ $# -le 2 ]
then
	echo "usage: $0 <workflow_name> <resource_name> cmd [cmd2 cmd3...]"
	exit 1
fi

resource_name=$1
workflow_name=$2

resetfile="reset_cmds-$resource_name-$workflow_name.tmp"

rm -f $resetfile
shift 2
for i in "$@"
do
	echo "$i" >> $resetfile
done

echo "file $resetfile now contains:"
cat $resetfile

