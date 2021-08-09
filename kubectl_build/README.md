# Kubebuilder

Author: [Gaëtan Lehmann](https://github.com/glehmann)

`kubectl_build` integrates [BuildKit CLI for kubectl](https://github.com/vmware-tanzu/buildkit-cli-for-kubectl), a tool for building OCI and Docker images with your kubernetes cluster, with tilt.

Having the images built directly in the cluster has several benefits:

* faster build cycles: no need to transfer the image from the current host to regitry, and from the registry to the cluster;
* smaller disk usage: when working with a local k8s instance like kind or docker desktop, we usually have 3 times the image on the local disk (one, for the builld output, one for the registry and a last one in the cluster). With kubectl_build, there is only one copy of the image, in the k8s cluster.


## Usage

`kubectl build` must be installed on your computer. See [BuildKit CLI for kubectl's Getting started](https://github.com/vmware-tanzu/buildkit-cli-for-kubectl#getting-started) for instructions.

Load the extension in your `Tiltfile`, and replace the `docker_build()` call by `kubectl_build()`.

``` python
load('ext://kubebuilder', 'kubectl_build')
kubectl_build('gcr.io/foo/bar', '.')
```

## Pulling image from private repository

By default, `kubectl_build` uses the `docker-registry` secret to pull the images, if it exists.

You can use another secret by passing the `registry_secret` argument to the `kubectl_build` call:

``` python
kubectl_build('gcr.io/foo/bar', '.', registry_secret='my-secret')
```

You may also set the `KUBECTL_BUILD_REGISTRY_SECRET` environment variable with the secret name.

## Limitations

`kubectl_build` supports almost all the `docker_build` arguments, excepted:

* `dockerfile_contents`
* `only`
* `container_args`
* `network`

some of these arguments may be added in the future (a pull request is welcome!).

BuildKit CLI for kubectl doesn't support `env` secrets at this time, so you have to convert them to file to use this extension.

BuildKit CLI for kubectl doesn't support all the local k8s clusters — k3d, for example, is know to not be supported.
