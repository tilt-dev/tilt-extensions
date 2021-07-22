## Workflow

Attach a workflow, or series of commands, to a resource.

```
workflow(workflow_name : string, resource_name : string, work_cmds=[[]] : [[string]], clear_cmd=[]: [string])
```

Each invocation of `workflow` creates a set of three buttons in the tilt UI:
* `play`: run the next command.
* `replay`: re-run the last command.
* `rewind`: run the reset command and start the workflow over.

Command outputs are shown in the Tilt UI.

All button IDs and temporary file names contain the workflow name and resource name.
This makes it possbile for multiple workflows to be attached to the same resource,
and for workflows with the same name to exist on different resources.


