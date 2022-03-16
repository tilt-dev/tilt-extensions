# Pulumi

Author: [Nick Santos](https://github.com/nicks)

Use [Pulumi](https://www.pulumi.com/) to deploy services to a cluster.

Use this to add a fast dev loop to your Pulumi-based projects.

## Requirements:

- Tilt v0.23.4+
- Pulumi
- Python3

## Functions

### pulumi_resource

```

def pulumi_resource(
    name,
    stack='',
    dir='',
    deps=[],
    image_deps=None,
    image_configs=None,
    image_selector='',
    container_selector='',
    live_update=None,
    resource_deps=None,
    labels=None,
    port_forwards=[]):
  ...
```

Installs a pulumi stack to a cluster.

Arguments:

`name`: The name of the resource in the Tilt UI.

`stack`: The Pulumi stack to operate on. Defaults to the current stack.

`dir`: The directory to run 'pulumi up' in. Defaults to the current working directory.

`deps`: A list of file dependencies that should trigger a deployment.

`image_deps`: A list of images built by Tilt to inject into the chart. If Tilt doesn't know
how to build one of these images, this will be an error.

`image_configs`: A list of config keys for how to inject images into the Pulumi stack.
Assumes that the stack uses Pulumi's Configuration API for injecting images.

`image_selector`: Image reference to determine containers eligible for Live Update.
  Only applicable if there are no images in `image_deps`.

`container_selector`: Container reference to determine containers eligible for Live Update.
  Only applicable if there are no images in `image_deps`.

`live_update`: Live Update steps for images not built by Tilt.
  Only applicable if there are no images in `image_deps`.

`resource_deps`: Tilt [resources to depend
on](https://docs.tilt.dev/resource_dependencies.html). Useful for adding a
dependency on a helm repo install.

`labels`: Labels for categorizing the resource.

`port_forwards`: Host port to connect to the pod. Takes the same form as `port_forwards` in [the `k8s_resource` command](https://docs.tilt.dev/api.html#api.k8s_resource).

## Example

See the [test](./test) directory for an example of a project that uses Pulumi to
deploy, then adds live-update and port-forwards on top.

## Future Work

Contributions welcome!

We mainly built this as a proof of concept to show how to integrate Tilt's
custom deploy system with other deploy tools.
