# Restart Process (Alpha)

🚨 Still Under Development! 🚨
This extension is still actively in development, use at your own risk.

This extension wraps a `docker_build` call such that at the end of a `live_update`, the container's process will rerun itself. (Use it in place of the `restart_container()` Live Update step, which doesn't work for all users and will soon be deprecated.)

## When to Use
Use this extension when you have an image (via `docker_build`) and you want to re-execute its entrypoint/command as part of a `live_update`.

E.g. if your app is a static binary, you'll probably need to re-execute the binary for any changes you made to take effect.

(If your app has hot reloading capabilities---i.e. it can detect and incorporate changes to its source code without needing to restart---you probably don't need this extension.)

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

TODO(maia) 👀

## Unsupported Cases
This extension does NOT support process restarts for:
- Docker images without shell support (e.g. `scratch`)
- Images run in Docker Compose resources
- `custom_build`
- ???

Run into a bug? Need a use case that we don't yet support? Let us know---[open an issue](https://github.com/windmilleng/tilt-extensions/issues) or [contact us](https://tilt.dev/contact).

## For Maintainers: Releasing
TODO(maia) 👀
