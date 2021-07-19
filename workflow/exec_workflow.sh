#!/usr/bin/env bash

WORKFLOW_INDEX=$(cat workflow_index.tmp | head -n 1)
echo "executing command $WORKFLOW_INDEX: '$( head -n $WORKFLOW_INDEX workflow_cmds.tmp | tail -n 1 )'"
$(head -n $WORKFLOW_INDEX workflow_cmds.tmp | tail -n 1)

