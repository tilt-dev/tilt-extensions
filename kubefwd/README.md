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

## Usage

Add these lines to your Tiltfile:

```python
v1alpha1.extension_repo(name='default', url='https://github.com/tilt-dev/tilt-extensions')
v1alpha1.extension(name='kubefwd:config', repo_name='default', repo_path='kubefwd')
```

When Tilt starts up for the first time, 
it will prompt up your native OS GUI for your sudo password.
Only `kubefwd` will get the `sudo` privileges.

## Future Work

### Namespaces

Currently, kubefwd only works for the `default` namespace.

In a follow-up PR, I want to add a controller that auto-configures kubefwd
for whatever namespaces you're deploying to.

### Pod Discovery

If a pod inside the cluster restarts, you need to reboot `kubefwd`.  You can do
this manually from the tilt UI (the refresh button) or from the CLI with `tilt
trigger kubefwd`.  Could we do something more automatic?

Possible solutions:

1) A system that watches the Tilt `KubernetesDiscovery` API and
  restarts it for you whenever the pods change.
  
2) Even better, a version of `kubefwd` that reads the pods from the Tilt API.
