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

## What's Happening Under the Hood

This extension makes use of [`entr`](https://github.com/eradman/entr/), a utility for running arbitrary commands when files change. Specifically, we override the container's entrypoint with the following:

```python
echo '/.restart-proc' | entr -rz <entrypoint>
```

This invocation says:
- when the container starts, run <entrypoint>
- whenever the `/.restart-proc` file changes, re-execute <entrypoint>
- `-z`: if <entrypoint> exits, `entr` should exit as well (so that k8s/Tilt can detect that the container has stopped)[¹](#fn1).

We also set the following as the last `live_update` step:
```python
run('date > /.restart-proc')
```

Because `entr` will re-execute the entrypoint whenever `/.restart-proc'` changes, the above `run` step will cause the entrypoint to re-run.

#### Provide `entr`
For this all to work, the `entr` binary must be available on the Docker image. The easiest solution would be to call e.g. `apt-get install entr` in the Dockerfile, but different base images will have different package mangers; rather than grapple with that, we've made a statically linked binary available on Docker image: [`tiltdev/entr`](https://hub.docker.com/repository/docker/tiltdev/entr).

If you want to build `image-foo`, this extension will:
- build your requested image as `image-foo-base` via `docker_build` call with all of your specified args/kwargs
- build `image-foo` (the actual image that will be used in your resource) as a _child_ of `image-foo-base`:
```Dockerfile
FROM tiltdev/entr:2020-16-04 as entr-img

FROM image-foo-base

# we'll use this file to signal restarts,
# make sure it exists
RUN ["touch", "/.restart-proc"]

# make the entr binary available on this image
COPY --from=entr-img /entr /
```

Thus, the final image produced is tagged `image-foo` and has all the properties of your original `docker_build`, plus access to the `entr` binary.

## Unsupported Cases
This extension does NOT support process restarts for:
- Docker images without shell support (e.g. `scratch`)
- Images run in Docker Compose resources
- `custom_build`
- ???

Run into a bug? Need a use case that we don't yet support? Let us know--[open an issue](https://github.com/windmilleng/tilt-extensions/issues) or [contact us](https://tilt.dev/contact).

## For Maintainers: Releasing
TODO(maia) 👀

---
### Notes
<a name="fn1"></a>**1**: the `-z` flag is only available in `entr` >= [v4.5](https://github.com/eradman/entr/releases/tag/4.5)
