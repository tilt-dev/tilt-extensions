# Earthly

Author: [Konrad Malik](https://github.com/konradmalik)

Use [Earthly](https://earthly.dev/) to build images for Tilt.

## Functions

### `earthly_build(target, ref, image_arg, deps, ignore=None, extra_flags=None, extra_args=None, live_update=[])`

- **context**: The dir where the earthly command will be executed relative to the Tiltfile.
- **target**: The name of the earthly target to build.
  Note that Earthly targets start with '+' but also can refer to targets
  in another dir or remote locations (see https://docs.earthly.dev/docs/guides/target-ref).
- **ref**: The name of the image that earthly will build (e.g. ‘myproj/backend’ or ‘myregistry/myproj/backend’).
  If this image will be used in a k8s resource(s), this ref must match the spec.container.image param for that resource(s).
- **image_arg**: the name of the earthly ARG that is responsible for setting the resulting image full name (name + tag)
- **deps**: Changes to the given files or directories that will trigger rebuilds. Relative to the Tiltfile. Defaults to `context`.
- **ignore**: Changes to the given files or directories do not trigger rebuilds.
- **extra_flags**: Extra flags to pass to earthly. Expressed as an argv-style array, ex. `['--strict']`.
- **extra_args**: Extra ARG key-pairs to pass to earthly. Expressed as an argv-style array, ex. `['--PORT=8000']`.
- **live_update**: Set of steps for updating a running container
  (see https://docs.tilt.dev/live_update_reference.html)

## Example Usage

```
load('ext://earthly', 'earthly_build')
earthly_build(
    context='.',
    target='+hello',
    ref='helloimage',
    image_arg='IMAGE_NAME',
    ignore='./test.sh',
    extra_flags=['--strict'],
    extra_args=['--PORT=8000'])
```
