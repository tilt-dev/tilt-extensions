# Tilt Inspsector

Author: [Nick Santos](https://github.com/nicks)

A small debugging server for viewing internal Tilt state.

## Functions

### tilt_inspector(port: int = 11350)

Exposes a tilt inspector server at the given port.

## Example Usage

```
load('ext://tilt_inspector', 'tilt_inspector')
tilt_inspector()
```

## Other notes

Requires yarn/nodejs.

One tilt inspector server can inspect arbitrarily many tilt instances.
