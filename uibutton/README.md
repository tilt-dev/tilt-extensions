# UIButton

Authors:
 * [Matt Landis](https://github.com/landism)
 * [Milas Bowman](https://github.com/milas)

Extend the Tilt UI with custom actions for your resources.

## Functions

### `cmd_button(name, resource, argv, text=None, location=location.RESOURCE, icon_name=None, icon_svg=None)`

Creates a button for a resource that runs the given command when clicked.

| Argument | Type | Description |
| -------- | ---- | ----------- |
| `name`      | `str`            | Unique ID for button |
| `resource`  | `str`            | Resource to associate button with (required if `location=location.RESOURCE`) |
| `argv`      | `List[str]`      | Local command to run when button is clicked |
| `text`      | `str`            | Text to display on button (optional: defaults to `name`) |
| `location`  | `str` (enum)     | Button placement in UI (see `location` section below) |
| `icon_name` | `str`            | Name of [Material Icons font ligature][material-icons-font] to use as icon (at most one of `icon_name` or `icon_svg` should be specified) |
| `icon_svg`  | `str` or `Blob`  | `<svg>` to use as icon; should have 24x24px viewport (at most one of `icon_name` or `icon_svg` should be specified) |

### `location`
To specify button location, you can bind the `location` helper type or pass a string, e.g. `location=location.NAV` and `location='nav'` are equivalent.

| Location   | `str` Value | `location` Value    |
| ---------- | ----------- | ------------------- |
| Resource   | `resource`  | `location.RESOURCE` |
| Global nav | `nav`       | `location.NAV`      |

## Example Usage

```python
load('ext://uibutton', 'cmd_button', 'location')

# define resource 'my-resource'
# k8s_resource('my-resource')

# create a button on resource 'my-resource'
cmd_button(name='my-resource-hello-world',
           resource='my-resource',
           argv=['echo', 'Hello my-resource!'],
           text='Hello World',
           icon_name='travel_explore')

cmd_button(name='nav-hello-world',
           argv=['echo', 'Hello nav!'],
           text='Hello World',
           location=location.NAV,
           icon_name='waving_hand')
```

## Button Placement
Currently, you can create buttons for a specific resource, which will be shown with other resource contextual actions such as "Copy Pod ID" or as part of the global nav next to the help and account buttons.

### Resource
To create a resource button, pass the resource name via `resource='my-resource'` and omit the `location` argument or explicitly pass `location=location.RESOURCE`.

Any command output will appear interleaved with the associated resource's logs.

Providing an icon is optional.

### Global Nav
To create a global nav button, pass `location=location.NAV` and omit the `resource` argument or explicitly pass `resource=None`.

Any command output will appear in the "All Resources" log view under `(global)`.

Global nav buttons SHOULD specify an icon via either the `icon_name` or `icon_svg` arguments. The `text` value will appear on hover.

## Icons
Button icons can either come from the set of built-in icons that ship with Tilt or a custom SVG.

Navbar buttons SHOULD include an icon as the button text is only visible on hover.
For resource buttons, icons are optional and will appear within the button if specified.

If both `icon_name` and `icon_svg` are specified, `icon_svg` will take precedence.

### Built-in Icons (Material Icons)
Tilt includes the [Material Icons][material-icons-font] by default.
Use the `icon_name` argument and pass the "font ligature" value for your desired icon.
The font ligatures are visible in the sidebar after clicking on an icon on the Material Fonts site.
Tip: They are `lower_snake_case` values, e.g. the "Check Circle" icon has a font ligature value of `check_circle`.

### Custom Icons (SVG)
Use the `icon_svg` argument and pass a full `<svg>` element.
The SVG viewport should be 24x24 for best results.

To avoid string quoting issues, it's often easiest to load the SVG from disk rather than storing it directly in your Tiltfile:
```python
load('ext://uibutton', 'cmd_button', 'location')

icon = read_file('./icon.svg')

cmd_button('svg-btn',
           argv=['echo', '✨ Hello from SVG ✨'],
           location=location.NAV,
           icon_svg=icon,
           text='SVG Nav Button') # text will appear on hover
```

## Other notes

Commands are executed locally on the host running `tilt up` (similar to `local_resource`).

The `argv` argument only accepts a list, e.g. `['echo', 'Hello World']` but not `echo 'Hello World'`.

To run a script, invoke the interpreter and then pass the script as an argument, e.g. `['bash', '-c', 'echo "Hello from bash ${BASH_VERSION}"']`.

## Known Issues
* Renamed/deleted buttons will not be removed until Tilt is restarted ([#193](https://github.com/tilt-dev/tilt-extensions/issues/193))

[material-icons-font]: https://fonts.google.com/icons
