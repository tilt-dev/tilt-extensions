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
- `path`: path to application directory, defaults to the current working directory
- `builder`: builder image, defaults to gcr.io/paketo-buildpacks/builder:base
- `buildpacks`: a list of buildpacks to use. (list[str])
- `env_vars`: a list of environment variables. (list[str])

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

## Requirements

- The `pack` binary must be on your path.
