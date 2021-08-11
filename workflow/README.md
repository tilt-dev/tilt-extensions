## Workflow

Attach a workflow, or series of commands, to a resource.

```
workflow(workflow_name : string, resource_name : string, work_cmds=[[]] : [[string]], clear_cmd=[]: [string])
```
Where `work_cmds` is an array of argv, and `clear_cmd` is a single argv. For example:
```
load('ext://workflow', 'workflow')

workflow(
	'my-workflow',
	resource_name='my-resource',
	work_cmds=[ ['echo', '1st'], ['echo', '2nd'], ['echo', '3rd'] ],
	clear_cmd=['echo', 'resetting...'],
)
```

Each invocation of `workflow` creates a set of three buttons in the tilt UI:
* `Next Step`: run the next command.
* `Re-run Step`: re-run the last command.
* `Reset`: run the reset command and start the workflow over.

Command outputs are shown in the Tilt UI in the associated resource's log view.

All button IDs and temporary file names contain the workflow name and resource name.
This makes it possible for multiple workflows to be attached to the same resource,
and for workflows with the same name to exist on different resources.

By default, workflow state files will be stored inside the `tilt_modules/workflow`
directory along with the extension. If you check your `tilt_modules/` directory into
source control, add `workflow_*.tmp` to your `.gitignore` or equivalent.
