# color
Add ANSI color codes to your Tiltfile log messages.

Works with Tiltfile built-ins such as `print`, `warn`, `fail`, `exit` in addition to custom functions.

## Usage
```python
load('ext://color', 'color')

print(color.red('ERROR: ') + 'Something went wrong')

print('The {earth} is about 71% {water}.'.format(
    earth=color.green('earth'),
    water=color.blue('water')
))
```

## API
All color functions take a single argument (the string to be colorized) and return a string.

Available color functions:
* `color.black`
* `color.red`
* `color.green`
* `color.yellow`
* `color.blue`
* `color.magenta`
* `color.cyan`
* `color.white`


## Enable/Disable
To disable colors from this extension, set the [`NO_COLOR`][no-color] environment variable, e.g. `NO_COLOR=1 tilt up`.

Additionally, unless forcibly enabled, when running `tilt ci`, if running on Windows or `TERM=dumb`, colors will be automatically disabled to prevent compatibility issues.

NOTE: Colors are automatically enabled when running `tilt up` regardless of OS/terminal support, as the Tilt web UI always supports color ANSI codes.

You can force colors from this extension by setting the `FORCE_COLOR` environment variable, e.g. `FORCE_COLOR=1 tilt up`.
(If both `NO_COLOR` and `FORCE_COLOR` are set, `NO_COLOR` will take precedence.)

[no-color]: https://no-color.org/
