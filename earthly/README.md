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
- **deps**: Changes to the given files or directories that will trigger rebuilds. Relative to the Tiltfile. Defaults to `context`. Only accepts real paths, not file globs.
- **ignore**: set of file patterns that will be ignored. Ignored files will not trigger builds. Follows the dockerignore syntax.
  Patterns/filepaths will be evaluated relative to each dep (e.g. if you specify deps=['dep1', 'dep2'] and ignores=['foobar'] , Tilt will ignore both deps1/foobar and dep2/foobar ).
- **extra_flags**: Extra flags to pass to earthly. Expressed as an argv-style array, ex. `['--strict']`.
- **extra_args**: Extra ARG key-pairs to pass to earthly. Expressed as an argv-style array, ex. `['--PORT=8000']`.
- **live_update**: Set of steps for updating a running container
  (see https://docs.tilt.dev/live_update_reference.html)

### `earthly_build_with_restart(context, target, ref, image_arg, entrypoint, deps=None, ignore=None, extra_flags=None, extra_args=None, live_update=[], base_suffix='-tilt_docker_build_with_restart_base', restart_file=RESTART_FILE, trigger=None, exit_policy='restart')`

- **context**: The dir where the earthly command will be executed relative to the Tiltfile.
- **target**: The name of the earthly target to build.
  Note that Earthly targets start with '+' but also can refer to targets
  in another dir or remote locations (see https://docs.earthly.dev/docs/guides/target-ref).
- **ref**: The name of the image that earthly will build (e.g. ‘myproj/backend’ or ‘myregistry/myproj/backend’).
  If this image will be used in a k8s resource(s), this ref must match the spec.container.image param for that resource(s).
- **image_arg**: the name of the earthly ARG that is responsible for setting the resulting image full name (name + tag)
- **entrypoint**: the command to be (re-)executed when the container starts or when a live_update is run
- **deps**: Changes to the given files or directories that will trigger rebuilds. Relative to the Tiltfile. Defaults to `context`. Only accepts real paths, not file globs.
- **ignore**: set of file patterns that will be ignored. Ignored files will not trigger builds. Follows the dockerignore syntax.
  Patterns/filepaths will be evaluated relative to each dep (e.g. if you specify deps=['dep1', 'dep2'] and ignores=['foobar'] , Tilt will ignore both deps1/foobar and dep2/foobar ).
- **extra_flags**: Extra flags to pass to earthly. Expressed as an argv-style array, ex. `['--strict']`.
- **extra_args**: Extra ARG key-pairs to pass to earthly. Expressed as an argv-style array, ex. `['--PORT=8000']`.
- **live_update**: Set of steps for updating a running container
  (see https://docs.tilt.dev/live_update_reference.html)
- **base_suffix**: suffix for naming the base image, applied as {ref}{base_suffix}
- **restart_file**: file that Tilt will update during a live_update to signal the entrypoint to rerun
- **trigger**: (optional) list of local paths. If specified, the process will ONLY be restarted when there are changes

## Example Usage

```python
load('ext://earthly', 'earthly_build')
earthly_build(
    context='.',
    target='+hello',
    ref='helloimage',
    image_arg='IMAGE_NAME',
    ignore='./test.sh',
    extra_flags=['--strict'],
    extra_args=['--PORT=8000'])

load('ext://earthly', 'earthly_build_with_restart')
earthly_build_with_restart(
    entrypoint='./main.sh',
    context='.',
    target='+hello',
    ref='helloimage',
    image_arg='IMAGE_NAME',
    ignore='./test.sh',
    extra_flags=['--strict'],
    extra_args=['--PORT=8000'],
    live_update=[run("echo 'updating!'")])
```
