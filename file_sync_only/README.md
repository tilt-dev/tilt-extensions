# "File Sync Only" development

Author: [MasayaAoyama](https://github.com/MasayaAoyama) from PLAID, Inc.

no-build, no-push, file sync only development.
we can use public image or existing private image for development.


## Usage

Specify image, manifests, and live_update command.
If image is included tag, manifests is updated by it's tag.

* Using image (nginx:1.16) written in manifests (./manifest.yaml)

```
load('ext://file_sync_only', 'file_sync_only')

file_sync_only("nginx",
    "./manifest.yaml",
    live_update=[
        sync("testfile", "/"),
    ],
)
```

or

* Not use manifests image tag, use specific image tag (e.g. 1.17 for nginx image)

```
load('ext://file_sync_only', 'file_sync_only')

file_sync_only("nginx:1.17",
    "./manifest.yaml",
    live_update=[
        sync("testfile", "/"),
    ],
)
```

## Example

```
# running tilt
$ cd test
$ (tilt up &)

# show file before file sync
$ kubectl exec -it nginx-8f48f9474-h7jgg -- cat /testfile
cat: /testfile: No such file or directory
command terminated with exit code 1

# touch file for sync test
$ date > testfile

# show file after file sync
$ kubectl exec -it nginx- -- cat /testfile
Sun Aug 23 21:00:00 UTC 2020
```

### Parameters

* `image` (str)
    * name for image
* `manifests` (str or List[str])
    * applying manifests
* `live_update` (List[LiveUpdateStep])
    * set of steps for updating a running container

## Requirements

* The `grep` binary must be on your path
* If you want to sync at the first time, please run something (e.g. `for i in `find . -type f`; do touch $i; sleep 1; done`)

