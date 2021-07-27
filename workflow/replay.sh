#!/usr/bin/env bash 

set -eou pipefail

if [ $# -ne 2 ]
then
	echo "usage: $0 <workflow_name> <resource_name>"
	exit 1
fi

./exec_workflow.sh "$@"
