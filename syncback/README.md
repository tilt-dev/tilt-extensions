# Syncback

This extension helps you sync files/directories from your container back to your local FS. Under the hood, it uses [`rsync`](https://rsync.samba.org/) to be smart about what files to transfer.

## Overview
This extension provides a function `syncback` which creates a manually-triggered local resource to sync files from a Kubernetes container back to your local filesystem. You can configure the source pod/container/directory/files+directories, and the destination location, as well as some other settings.

Whenever you want to sync files back from the pod to your local filesystem, invoke the local resource from the Web UI:
<IMAGE HERE>

### Usage
First, **make sure you have an up-to-date `rsync` on your local machine** (version >= 3.0.0).

Import this extension by putting the following at the top of your Tiltfile:
```
load('ext://syncback', 'syncback')
```

For every syncback resource you want to create, invoke `syncback` with the following parameters:

* **name (str)**: name of the created local resource
* **k8s_object (str)**: a Kubernetes object identifier (e.g. `deploy/my-deploy`, `job/my-job`, or a pod ID) that Tilt can use to select a pod. As per the behavior of `kubectl exec`, we will act on the first pod of the specified object, using the first container by default
* **src_dir (str)**: directory *in the remote container* to sync from. Any `paths`, if specified, should be relative to this dir. This path *must* be a directory and must contain a trailing slash (e.g. `/app/` is acceptable; `/app` is not)

You may also pass the following optional parameters:
* **paths (List[str], optional)**: paths *in the remote container* to sync, relative to `src_dir`. May be files or directories. Note that these must not begin with `./`. If no paths are provided, we sync the entire `src_dir`
* **target_dir (str, optional)**: directory *on the local filesystem* to sync to. Defaults to `'.'`
* **container (str, optiona)**: name of the container to sync from (by default, the first container)
* **namespace (str, optiona)**: namespace of the desired `k8s_object`, if not `default`.
* **verbose (bool, optional)**: if true, print additional rsync information.

Some example invocations:
```python
# Create a local resource called "syncback-js" which connects to the first pod of
#   "deploy/frontend" (and the default container) and syncs "/app/package.json" and
#   "/app/yarn.lock" to local directory "./frontend".
syncback('syncback-js', 'deploy/frontend', '/app/',
         target_dir='./frontend',
         paths=['package.json', 'yarn.lock']
)

# Create a local resource called "syncback-portal" which connects to the first pod of
#   "deploy/portal-app" (to container "app") in namespace $(whoami), and syncs the
#   entire contents of "src/node_modules" to local directory "./portal/node_modules".
ns = str(local('whoami')).strip()
syncback('syncback-portal', 'deploy/portal-app', '/src/node_modules/',
         target_dir='./portal/node_modules',
         container='app',
         namespace=ns
)

# Create a local resource called "syncback-data" which connects to the first pod of
#   "job/data-cron" syncs the contents of "/data" to "."
syncback('syncback-data', 'job/data-cron', '/data/')
```

You can create as many syncback resources as you like; you'll need at minimum one syncback resource for every remote container you want to copy from, but you might choose to have different syncback resources for different sets of files, e.g. one to copy back `node_modules` and one to copy back your `data/` directory.

### Gotchas
#### Tilt updates your pod after a syncback
If `fileX` changes on the remote container and your syncback task copies `fileX` back to your local machine, then depending on your project setup, Tilt may register this file change and rebuild the associated resource. This is expected behavior--there's no good way to determine whether a file changed because it was edited locally, or if it was synced back from a container.

If you're using [Live Update](https://docs.tilt.dev/live_update_tutorial.html), we expect the update that runs after syncback to be a no-op, and super fast. If this extra update is bothering you, here are some things that might help:
1. if you're not already using Live Update, start; instead of a whole image rebuild, Tilt will just copy over the changed files, and you'll save lots of time.
2. if you're already using Live Update but it's still too slow, consider making use of [`run` triggers](https://docs.tilt.dev/live_update_reference.html#run-triggers) to ensure that your run steps only execute when they need to (e.g. if you run a `go build` as part of your Live Update, use triggers to make sure it only runs when packages in `./internal` change).
3. if you never want `fileX` to trigger a Tilt update, ignore it with `.tiltignore` or `watch_settings(ignore=)` ([see docs](https://docs.tilt.dev/file_changes.html#tiltignore)).

#### Syncback isn't finding the files I expect it to
Kubernetes might have connected you to the wrong pod. If you're passing any `k8s_object` besides a pod ID (e.g. `deploy/my-deploy`), the syncback will run on the first pod Kubernetes finds belonging to that object. If you run the syncback at a time when there are old pods hanging around--e.g. right after Tilt deployed a new pod, the old pod might take a few seconds to start shutting down--then you risk running the syncback on an out-of-date pod. We recommend waiting a few seconds/waiting until `kubectl get pods` shows only the pods you expect to, and trying again.

## Nitty Gritty Details

### How We Pick Pods
Under the hood, this script uses `kubectl exec` to run `rsync` (and some other assorted commands). [As detailed here](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec), you may call `kubectl exec` on a specific pod, *or on any Kubernetes object specified as `TYPE/NAME`*; in the latter case, the command executed on the first pod belonging to that object.

### About Syncing
Under the hood, this extension uses [`rsync`](https://rsync.samba.org/). `Rsync`, which stands for "remote sync", is a remote and local file synchronization tool. It uses an algorithm that minimizes the amount of data copied by only moving the portions of files that have changed.[^1]

`rsync` isn't the simplest implementation here--it might have been easier to run `kubectl cp <POD>:/src_dir ./target_dir`, for instance. We chose `rsync` because:
* it handles deletions and file renames, which the the `kubectl cp` solution above does not
* it's more efficient: if only 2MB of files have changed within a 2GB directory, you want to copy down only what has changed, and avoid moving multiple gigs of data

This extension uses the `krsync.sh` script (adapted from [Karl Bunch's elegant script on Server Fault](https://serverfault.com/questions/741670/rsync-files-to-a-kubernetes-pod/887402#887402)) to bridge the gap between `rsync` and Kubernetes. As part of that script, we copy our pre-built `rsync` binary onto the container, and use that binary for all subsequent `rsync` calls.

### Unsupported/Future Work
(Need this functionality? Need something else not listed here? [Let us know](https://github.com/tilt-dev/tilt-extensions/issues)!)
* specifying excludes: right now you can specify files to include, but not files to exclude)
* `rsync`-specific syntax: `rsync` has its own semantics, e.g. specific meanings for directories with and without a trailing slash, or for `*` vs. `**` vs. `***`. This extension converts your arguments into our best guess of their `rsync` translation, but `rsync` experts might want more fine-grained control
* running on Windows containers: our pre-built Linux `rsync` binary definitely won't run on Windows containers
* running automatically in response to file/resource changes: it would be neat if Tilt knew when syncbacks were needed (because `fileX` changed locally, because Resource Y updated, or even if `fileZ` changed in the container), but currently this isn't supported

## For Maintainers: Updating `rsync` Binary
tk

[^1]: https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories
