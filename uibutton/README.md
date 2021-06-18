# UIButton

Authors:
 * [Matt Landis](https://github.com/landism)
 * [Milas Bowman](https://github.com/milas)

Extend the Tilt UI with custom actions for your resources.

## Functions

### cmd_button(name, resource, argv, text='')

Creates a button for a resource that runs the given command when clicked.

| Argument | Type | Description |
| -------- | ---- | ----------- |
| `name` | `str` | Unique ID for button |
| `resource` | `str` | Resource to associate button with |
| `argv` | `List[str]` | Local command to run when button is clicked |
| `text` | `str` | Text to display on button (optional: defaults to `name`) |


## Example Usage

```
load('ext://uibutton', 'cmd_button')

# define resource 'my-resource'
# k8s_resource('my-resource')

# create a button on resource 'my-resource'
cmd_button(name='Hello World',
           resource='my-resource',
           argv=['echo', 'Hello World'])
```

## Other notes

The `argv` argument only accepts a list, e.g. `['echo', 'Hello World']` but not `echo 'Hello World'`.

The command is executed directly; to run a script, invoke the interpreter and then pass the script as an argument, e.g. `['bash', '-c', 'echo "Hello from bash ${BASH_VERSION}"']`.

Any command output will appear interleaved with the associated resource's logs.
