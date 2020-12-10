# Syncback: More Info

This doc contains low-level details about the Syncback extension. Most developers won't need to touch this doc, but it's here to provide additional information if you're trying to debug something or are just curious. Still having trouble? [Let us know](https://github.com/tilt-dev/tilt-extensions/issues)!

## Gotchas
### Tilt updates my pod after a syncback
If `fileX` changes on the remote container and your syncback task copies `fileX` back to your local machine, then depending on your project setup, Tilt may register this file change and rebuild the associated resource. This is expected behavior--there's no good way to determine whether a file changed because it was edited locally, or if it was synced back from a container.

If you're using [Live Update](https://docs.tilt.dev/live_update_tutorial.html), we expect the update that runs after syncback to be a no-op, and super fast. If this extra update is bothering you, here are some things that might help:
1. if you're not already using Live Update, start; instead of a whole image rebuild, Tilt will just copy over the changed files, and you'll save lots of time.
2. if you're already using Live Update but it's still too slow, consider making use of [`run` triggers](https://docs.tilt.dev/live_update_reference.html#run-triggers) to ensure that your run steps only execute when they need to (e.g. if you run a `go build` as part of your Live Update, use triggers to make sure it only runs when packages in `./internal` change).
3. if you never want `fileX` to trigger a Tilt update, ignore it with `.tiltignore` or `watch_settings(ignore=)` ([see docs](https://docs.tilt.dev/file_changes.html#tiltignore)).

### Syncback isn't finding the files I expect it to
Kubernetes might have connected you to the wrong pod. If you're passing any `k8s_object` besides a pod ID (e.g. `deploy/my-deploy`), the syncback will run on the first pod Kubernetes finds belonging to that object. If you run the syncback at a time when there are old pods hanging around--e.g. right after Tilt deployed a new pod, the old pod might take a few seconds to start shutting down--then you risk running the syncback on an out-of-date pod. We recommend waiting a few seconds/waiting until `kubectl get pods` shows only the pods you expect to, and trying again.

## Notes on Implementation

### How We Pick Pods
Under the hood, this script uses `kubectl exec` to run `rsync` (and some other assorted commands). [As detailed here](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec), you may call `kubectl exec` on a specific pod, *or on any Kubernetes object specified as `TYPE/NAME`*; in the latter case, the command executed on the first pod belonging to that object.

### About Syncing
Under the hood, this extension uses [`rsync`](https://rsync.samba.org/). `Rsync`, which stands for "remote sync", is a remote and local file synchronization tool. It uses an algorithm that minimizes the amount of data copied by only moving the portions of files that have changed.[^1]

`rsync` isn't the simplest implementation here--it might have been easier to run `kubectl cp <POD>:/src_dir ./target_dir`, for instance. We chose `rsync` because:
* it handles deletions and file renames, which the the `kubectl cp` solution above does not
* it's more efficient: if only 2MB of files have changed within a 2GB directory, you want to copy down only what has changed, and avoid moving multiple gigs of data

This extension uses the `krsync.sh` script (adapted from [Karl Bunch's elegant script on Server Fault](https://serverfault.com/questions/741670/rsync-files-to-a-kubernetes-pod/887402#887402)) to bridge the gap between `rsync` and Kubernetes. As part of that script, we copy our pre-built `rsync` binary onto the container, and use that binary for all subsequent `rsync` calls.
