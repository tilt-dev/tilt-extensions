# Min Tilt Version

Author: [David Rubin](https://github.com/drubin)

Specify a minimum Tilt version to run this TiltFile

If the minimum version is not met, Tilt will stop executing using the `fail` api

## Usage

It's advisable to include this as close to the top of the Tiltfile as possible.

Include patch version

```py
load('ext://min_tilt_version', 'min_tilt_version')
min_tilt_version('0.13.0')
```

Only care about minor

```py
load('ext://min_tilt_version', 'min_tilt_version')
min_tilt_version('0.13')
```

## Requirements

* `tilt` binary must be in your path
