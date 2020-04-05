# Min Tilt Version

Allows you to specify a minimum tilt version to run required this TiltFile

Requiring a minimum will cause tilt to stop execution using `fail` api

## Usage

Its advisable to include this as close to the top of the `Tiltfile` as possible.

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
