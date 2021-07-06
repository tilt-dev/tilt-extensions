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
| `name`      | `str`            | Unique ID for button |
| `resource`  | `str`            | Resource to associate button with (required if `nav=False`) |
| `argv`      | `List[str]`      | Local command to run when button is clicked |
| `text`      | `str`            | Text to display on button (optional: defaults to `name`) |
| `icon_name` | `str`            | Name of [Material Icons font ligature][material-icons-font] to use as icon |
| `icon_svg`  |  `str` or `Blob` | `<svg>` to use as icon; should have 24x24px viewport |
| `nav`       | `bool`           | If `True`, button will appear in global nav; otherwise, will be in resource view for specified resource |

## Button Placement
Currently, you can create buttons for a specific resource, which will be shown with other resource contextual actions such as "Copy Pod ID" or as part of the global nav next to the help and account buttons.

### Resource
To create a resource button, pass the resource name via `resource='my-resource'` and `nav=False`.

Any command output will appear interleaved with the associated resource's logs.

Providing an icon is optional.

### Global Nav
To create a global nav button, pass `nav=True` and omit resource or pass `resource=None`.

Any command output will appear in the "All Resources" log view under `(global)`.

Global nav buttons SHOULD specify an icon via either the `icon_name` or `icon_svg` arguments. The `text` value will appear on hover.

## Example Usage

```
load('ext://uibutton', 'cmd_button')

# define resource 'my-resource'
# k8s_resource('my-resource')

# create a button on resource 'my-resource'
cmd_button(name='my-resource-hello-world',
           resource='my-resource',
           argv=['echo', 'Hello World'],
           text='Hello World',
           icon_name='travel_explore')
```

## Other notes

Commands are executed locally on the host running `tilt up` (similar to `local_resource`).

The `argv` argument only accepts a list, e.g. `['echo', 'Hello World']` but not `echo 'Hello World'`.

To run a script, invoke the interpreter and then pass the script as an argument, e.g. `['bash', '-c', 'echo "Hello from bash ${BASH_VERSION}"']`.

## Known Issues
* Renamed/deleted buttons will not be removed until Tilt is restarted ([#193](https://github.com/tilt-dev/tilt-extensions/issues/193))

[material-icons-font]: https://fonts.google.com/icons
