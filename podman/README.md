# Podman

Author: [Nick Santos](https://github.com/nicks)

Use Podman (https://podman.io/) to build images for Tilt.

## Functions

### `podman_build(ref: str, context: str, extra_flags?: [str])`

- **ref**: The name of the image to build. Must match the image
   name in the Kubernetes resources you're deploying.
- **context**: The build context of the binary to build. Expressed as a file path.
- **ignore**: Changes to the given files or directories do not trigger rebuilds.
      Does not affect the build context.
- **extra_flags**: Extra flags to pass to podman build.
- **live_update**: Set of steps for updating a running container
      (see https://docs.tilt.dev/live_update_reference.html)

## Example Usage

```
load('ext://podman', 'podman_build')
podman_build('hello-world-image', '.')
```

## Troubleshooting

### Error copying image

If you see this error message:

```
Error copying image to the remote destination: Error trying to reuse blob sha256:67f770da229bf16d0c280f232629b0c1f1243a884df09f6b940a1c7288535a6d at destination: error pinging docker registry localhost:5000: Get "https://localhost:5000/v2/": http: server gave HTTP response to HTTPS client
```

This means Podman cannot push to your image registry. 

Podman's support for registries is less mature than Docker's. The easiest way
to handle this is to manually edit `/etc/containers/registries.conf`
to add 'localhost' under the 'registries.insecure' heading.

```
[registries.insecure]
registries = ['localhost']
```
