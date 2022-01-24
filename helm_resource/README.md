# Helm Resource

Author: [Nick Santos](https://github.com/nicks)

Use [Helm](https://helm.io/) to deploy services to a cluster.

Prefer this extension to `helm_remote` for new projects.

## Requirements:

- Tilt v0.23.4+
- Helm 3

## Functions

### helm_resource

```

def helm_resource(
    name,
    chart,
    deps=[],
    release_name='',
    namespace=None,
    image_deps=None,
    image_keys=None,
    flags=None,
    image_selector='',
    container_selector='',
    live_update=None,
    resource_deps=None,
    labels=None):
  ...
```

Installs a helm chart to a cluster.

Arguments:

`name`: The name of the resource in the Tilt UI.

`chart`: A reference to a chart. Uses the same syntax as `helm install
[release-name] [chart]`. May be a local path, a local tarball, or a `repo/name`
reference.

`deps`: A list of file dependencies that should trigger a deployment.

`release_name`: The name of the release. If not specified, defaults to the Tilt UI resource name.

`namespace`: Install into the specified namespace.

`image_deps`: A list of images built by Tilt to inject into the chart. If Tilt doesn't know
how to build one of these images, this will be an error.

`image_keys`: A list of specifications for how to inject images into the
chart. Must be the same length as `image_deps`.  There are two common patterns.

- If your chart accepts an image as a single tagged image reference, specify the key as a string.

- If your chart accepts an image as a 'repository' and a 'tag', spectify the key
  as a tuple ('image.repository', 'image.tag'). This is how charts created with
  `helm create` are structured.

`flags`: Additional flags to pass to `helm install` (e.g., `['--set', 'key=value']`)

`image_selector`: Image reference to determine containers eligible for Live Update.
  Only applicable if there are no images in `image_deps`.
  
`container_selector`: Container reference to determine containers eligible for Live Update.
  Only applicable if there are no images in `image_deps`.
  
`live_update`: Live Update steps for images not built by Tilt.
  Only applicable if there are no images in `image_deps`.

`resource_deps`: Tilt resources to depend on. Useful for adding a dependency on a helm repo install.

`labels`: Labels for categorizing the resource.

### helm_repo

```
def helm_repo(
    name,
    url,
    username='',
    password='',
    **kwargs):
  ...
```

Installs a helm repo on tilt up.

Arguments:

`name`: The name of the helm repo.

`url`: The url of the helm repo.

`username`: The username for authenticating (if the helm repo is private).

`password`: The password for authenticating (if the helm repo is private).

`**kwargs:` Arguments to pass to the underlying resource like `labels` (for organization).

## Examples

See the [test directory](./test/Tiltfile) for a simple example.

## Implementation Notes

### Previous Approaches

In a Tilt environment, there are a few different approaches to installing a Helm chart.

- You can use `local()` or `local_resource()` to invoke `helm upgrade
  --install` as a local shell script.  This works and is easy to get
  started. But Tilt has no way to "see" what the shell scripts are installing,
  or monitoring them after they're done.
  
- Tilt offers a built-in `helm()` command that converts local Helm charts into
  Kubernetes YAML. `k8s_yaml(helm('./path/to/chart'))` registers the resources
  so that Tilt can deploy them. This works well for simple charts. Helm 3 has
  lots of great features for customizing the install process (e.g., waiting on
  CRD installation) that this approach misses out on.
  
- [Bob Jackman](https://github.com/kogi) wrote a `helm_remote` Tilt extension.
  `helm_remote` downloaded a remote chart, unpacked it on local disk, converted 
  it to Kubernetes YAML, then registered that YAML with Tilt. Because
  people often used this to install Kuberentes CRDs and operators,
  `helm_remote` would register CRDs as a separate resource and use
  Tilt's dependency-management to customize the install process.
  
You can read more in the [Tilt Helm Docs](https://docs.tilt.dev/helm.html)
  
### How this Approach is Different

Tilt now has a `k8s_custom_deploy` built-in that lets you use arbitrary shell
scripts to deploy resources, without losing Tilt's ability to monitor health,
stream logs, and sync live-updates.

`helm_resource` is a `k8s_custom_deploy` wrapper that deploys with Helm.  More
importantly, it incorporates a lot of what the Kubernetes community has learned
about how to group packages of YAML for installation. You can see this in the
evolution from Helm 2 to Helm 3.

### Future Work

Currently, `helm_repo` doesn't try to keep the repo up to date.

In the past, we've found it difficult to efficiently manage this information
from the Tiltfile. Ideally, `tilt up` against an existing environment should be
well-cached and fast. But maybe there are ways to do this with UIButtons that
manually trigger a repo update.

## Acknowledgements

Thanks to [Bob Jackman](https://github.com/kogi) for the original `helm_remote`
and a lot of the early experiments with Helm charts.

This extension is based an an early POC [Milas Bowman](https://github.com/milas)
wrote for `k8s_custom_deploy`.
