# Restart Process (Alpha)

### 🚨 Still Under Development! 🚨

This extension is still actively in development, use at your own risk.

This extension wraps a `docker_build` call such that at the end of a `live_update`, the container's process will rerun itself. (Use it in place of the `restart_container()` Live Update step, which doesn't work for all users and will soon be deprecated.)

## When to Use
Use this extension when you have an image (via `docker_build`) and you want to re-execute its entrypoint/command as part of a `live_update`.

E.g. if your app is a static binary, you'll probably need to re-execute the binary for any changes you made to take effect.

(If your app has hot reloading capabilities--i.e. it can detect and incorporate changes to its source code without needing to restart--you probably don't need this extension.)

## How to Use

Import this extension by putting the following at the top of your Tiltfile:
```python
load('ext://restart_process', 'docker_build_with_restart')
```

For the image that needs the process restart, replace your existing `docker_build` call:
```python
docker_build(
    'foo-image',
    './foo',
    arg1=val1,
    arg2=val2,
    live_update=[x, y, z...]
)
```
with a `docker_build_with_restart` call:
```python
docker_build_with_restart(
    'foo-image',
    './foo',
    '/go/bin/foo',
    arg1=val1,
    arg2=val2,
    live_update=[x, y, z...]
)
```
The call above looks just like the initial `docker_build` call except for one added parameter, `entrypoint` (in this example, `/go/bin/foo`). This is the command that you want to run on container start and _re-run_ on Live Update.

## Unsupported Cases
This extension does NOT support process restarts for:
- Images run in Docker Compose resources
- `custom_build`

Run into a bug? Need a use case that we don't yet support? Let us know--[open an issue](https://github.com/windmilleng/tilt-extensions/issues) or [contact us](https://tilt.dev/contact).

## What's Happening Under the Hood
*If you're a casual user/just want to get your app running, you can stop reading now. However, if you want to dig deep and know exactly what's going on, or are trying to debug weird behavior, read on._

This extension wraps commands in `tilt-restart-wrapper`, which makes use of [`entr`](https://github.com/eradman/entr/)
to run arbitrary commands whenever a specified file changes. Specifically, we override the container's entrypoint with the following:

```
/tilt-restart-wrapper --watchfile='/.restart-proc' <entrypoint>
```

This invocation says:
- when the container starts, run <entrypoint>
- whenever the `/.restart-proc` file changes, re-execute <entrypoint>

We also set the following as the last `live_update` step:
```python
run('date > /.restart-proc')
```

Because `tilt-restart-wrapper` will re-execute the entrypoint whenever `/.restart-proc'` changes, the above `run` step will cause the entrypoint to re-run.

#### Provide `tilt-restart-wrapper`
For this all to work, the `entr` binary must be available on the Docker image. The easiest solution would be to call e.g. `apt-get install entr` in the Dockerfile, but different base images will have different package mangers; rather than grapple with that, we've made a statically linked binary available on Docker image: [`tiltdev/entr`](https://hub.docker.com/repository/docker/tiltdev/entr).

To build `image-foo`, this extension will:
- build your image as normal (via `docker_build`, with all of your specified args/kwargs) but with the name `image-foo-base`
- build `image-foo` (the actual image that will be used in your resource) as a _child_ of `image-foo-base`, with the `tilt-process-wrapper` and its dependencies available

Thus, the final image produced is tagged `image-foo` and has all the properties of your original `docker_build`, plus access to the `tilt-restart-wrapper` binary.

#### Why a Wrapper?
Why bother with `tilt-restart-wrapper` rather than just calling `entr` directly?

Because in its canonical invocation, `entr` requires that the file(s) to watch be piped via stdin, i.e. it is invoked like:
```
echo "/.restart-proc" | entr -rz /bin/my-app
```

When specified as a `command` in Kubernetes or Docker Compose YAML (this is how Tilt overrides entrypoints), the above would therefore need to be executed as shell:
```
/bin/sh -c 'echo "/.restart-proc" | entr -rz /bin/my-app'
```
Any `args` specified in Kubernetes/Docker Compose are attached to the end of this call, and therefore in this case would apply TO THE `/bin/sh -c` CALL, rather than to the actual command run by `entr`; that is, any `args` specified by the user would be effectively ignored.

In order to make `entr` executable as ARGV rather than as shell, we have wrapped it in a binary that can be called directly and takes care of the piping under the hood.

Note: ideally `entr` could accept files-to-watch via flag instead of stdin, but (for a number of good reasons) this feature isn't likely to be added any time soon (see [entr#33](https://github.com/eradman/entr/issues/33)).

## For Maintainers: Releasing
If you have push access to the `tiltdev` on DockerHub, you can release a new version of this extension like so:
1. run `release.sh` (builds `tilt-restart-wrapper` from source, builds and pushes a Docker image with the new binary and a fresh binary of `entr` also installed from source)
2. update the image tag in the [Tiltfile](/Tiltfile) with the tag you just pushed (you'll find the image referenced in the Dockerfile contents of the child image--look for "FROM tiltdev/restart-helper")
