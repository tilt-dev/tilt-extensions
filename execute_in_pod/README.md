# Execute in pod

Author: [Llandy Riveron Del Risco](https://github.com/Llandy3d)

Execute a command in a pod container.

## Usage

### Execute a command inside a pod container.

```python
load('ext://execute_in_pod', 'execute_in_pod')

execute_in_pod('pod_name', 'echo "Echoing inside the container!"')
```

Given the `pod_name` it will check that the discovery exists, it will find the pod name and execute the command inside of it. If multiple pods are found for a given `pod_name` it will execute the command only on the first one.

It is possible to chain commands together if you need to execute many. `execute` will return the string of the command instead of running it directly.

```python
load('ext://execute_in_pod', 'execute_in_pod')

to_execute = [
    execute_in_pod('pod_name', 'echo 1', execute=False),
    execute_in_pod('pod_name', 'echo 2', execute=False),
    execute_in_pod('pod_name', 'echo 3', execute=False),
]

commands = '&& '.join(to_execute)
# commands can be given for example to a local_resource to run them.
```

##### Parameters

```python
execute_in_pod(pod_name, command, container=None, execute=True, quiet=True, echo_off=False)
```

* `pod_name` ( str ) – the name of the workload that will be used to retrieve pod names.
* `command` ( str ) – the actual command that will be executed inside of the pod container.
* `container` ( str ) – If specified, will run the command inside that container. If not, it will run on the default one.
* `execute` ( bool ) – By default the command will be immediately executed. You can set it to `False` to return the string of the command instead.
* `quiet` ( bool ) – `local` function quiet boolean. By default command output won't be logged.
* `echo_off` ( off ) – `local` function echo_off boolean. By default we do log the commands run.
