# Kubefwd

Author: [Nick Santos](https://github.com/nicks)

Kubernetes bulk service port-forwarding.

Want to use Kubernetes DNS addresses but don't want to run in a cluster?

`kubefwd` is a little server that updates your `/etc/hosts` so
that addresses resolve like they would inside Kubernetes.

https://kubefwd.com/

## Requirements

- `bash`
- `kubefwd`
- `entr`
- GNU core utils (`tr`, `sort`) - `brew install coreutils`

## Usage

Add these lines to your Tiltfile:

```python
v1alpha1.extension_repo(name='default', url='https://github.com/tilt-dev/tilt-extensions')
v1alpha1.extension(name='kubefwd:config', repo_name='default', repo_path='kubefwd')
```

When Tilt starts up for the first time, it will prompt up your native OS GUI for
your sudo password.  Only `kubefwd` and its operator will get the `sudo`
privileges.

The `kubefwd` operator will watch Tilt to see what namespaces you're deploying
to, then configure `kubefwd` for that namespace.

## Future Work

### Pod Discovery

If a pod inside the cluster restarts, you need to reboot `kubefwd`.  You can do
this manually from the tilt UI (the refresh button) or from the CLI with `tilt
trigger kubefwd:run`.  Could we do something more automatic?

Possible solutions:

1) A system that watches the Tilt `KubernetesDiscovery` API and
  restarts it for you whenever the pods change.
  
2) Even better, a version of `kubefwd` that reads the pods from the Tilt API.

Currently, this extension uses `entr` to restart `kubefwd`
without requesting new credentials.

### Kubefwd without deploys

The default mode of this extension is to run kubefwd for namespaces
where you're deploying.

In the future, we'd like to be able to support kubefwd for manually-configured
namespaces.

For example, you might be running `kubefwd` against a read-only cluster,
and only running local services for editing.

### Multi-cluster kubefwd

Long-term, we'd like to be able to run kubefwd against multiple clusters at once
(e.g., a read-only staging cluster and a writable dev cluster and a local KIND
cluster.)


