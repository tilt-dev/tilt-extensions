# Kubernetes Attach

Author: [Nick Santos](https://github.com/nicks)

Attach to an existing object that's already in your Kubernetes cluster.

## Usage

You dev environment may rely on shared servers, or servers
that are maintained by a platform team.

You can view the logs for these servers, monitor their health, live-update
changed files, and run remote commands.

For view-only attachment to a server, add this to your Tiltfile:

```
load('ext://k8s_attach', 'k8s_attach')
k8s_attach('my-busybox', 'deployment/my-busybox')
```

To copy files to the server whenever they change locally, add this:

```
load('ext://k8s_attach', 'k8s_attach')
k8s_attach('my-server', 'deployment/my-server', 
  image_selector='busybox', # the image to live-update
  live_update=[
    sync('./static', '/app/static').
    run('echo done'),
  ])
```

See the [test](./test) directory for an example.
