# Use Pack to build container images

Author: [Gareth Rushgrove](https://github.com/garethr)

Build container images using [pack](https://buildpacks.io/docs/install-pack/) and [buildpacks](https://buildpacks.io/).

## Usage

This extension adds the `pack` function, which is used the same way as `docker_build` to allow Tilt
to automatically build a container image with a known name. For instance the following example shows
building an image using the default builder and having that image automatically deployed to Kubernetes.

```python
load('ext://pack', 'pack')

pack('example-image')
k8s_yaml('kubernetes.yaml')
k8s_resource('example-deployment', port_forwards=8000)
```

The `pack` function can take a few arguments:

- `name`: name of the image to be built
- `pull_policy`: pull policy used by pack, defaults to `if-not-present`
- `path`: path to application directory, defaults to the current working directory
- `builder`: builder image, defaults to gcr.io/paketo-buildpacks/builder:base
- `deps`: a list of dependencies, defaults to `path`
- `buildpacks`: a list of buildpacks to use. (list[str])
- `env_vars`: a list of environment variables, defaults to `BP_LIVE_RELOAD_ENABLED=true` (list[str])

The function also supports all of the properties of [`custom_build`](https://docs.tilt.dev/api.html#api.custom_build) so
you can ignore files, override the entrypoint or set live updates as usual.

For instance, if you want to use the tiny builder instead of the default [Paketo](https://paketo.io/) one,
you would do the following:

```python
pack(
  'example-image',
  builder='gcr.io/paketo-buildpacks/builder:tiny'
)
```

## Examples

### Java

1. Use the [Tilt example repo](https://github.com/tilt-dev/tilt-example-java)
2. Use the following `Tiltfile`

```
# -*- mode: Python -*-

load('ext://pack', 'pack')

pack(
    'example-java-image',
    deps=['./bin/main'],
    live_update = [
        sync('./bin/main', '/workspace/BOOT-INF/classes'),
    ],
)
k8s_yaml('kubernetes.yaml')
k8s_resource('example-java', port_forwards=8000)
```

Then `tilt up`. Modifications are live synced into the application container.

This example requires Visual Studio Code with the Java and Gradle extensions. VS Code will compile on save and put the compiled changes in `./bin/main`. Tilt then syncs those into the container. You will need to adjust the `deps` and `live_update` path if you're using a different IDE or building with Gradle directly where compiled artifacts are placed in a different location.

### Node.js

1. Use the [Tilt example repo](https://github.com/tilt-dev/tilt-example-nodejs)
2. Use the following `Tiltfile`

```
# -*- mode: Python -*

load('ext://pack', 'pack')

pack(
    'example-nodejs-image',
    live_update = [
        sync('./', '/workspace/'),
    ])

k8s_yaml('kubernetes.yaml')
k8s_resource('example-nodejs', port_forwards=8000)
```

Then `tilt up`. Modifications are live synced into the application container.

## Requirements

- The `pack` binary must be on your path.
