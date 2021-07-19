#!/usr/bin/env bash

echo "executing command: '$(head -n 1 workflow_cmds.tmp)'"
$(head -n 1 workflow_cmds.tmp)

