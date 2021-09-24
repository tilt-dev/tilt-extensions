## List resources being blocked by dependencies

A simple extension that displays a list of which resources are being blocked by dependencies,
as well as the specific dependencies they are waiting for, 
via a UI button on the `(Tiltfile)` resource.

A sample output could look like this:
```
---- Resources waiting for dependencies ----
Resource 'b' is blocking on 'a'.
Resource 'c' is blocking on 'a' and 'b'.
Resource 'd' is blocking on 'c'.
--------------------------------------------
```

Or, if no resources are currently blocked, like this:
```
---- Resources waiting for dependencies ----
No resources blocked at the moment.
--------------------------------------------
```

For this demo, we assume that if one pod is ready, then anything that depends on it can start building.
The real relationship between readiness and resource dependencies is a bit more complicated.
Pods can go from crashing to ready back to crashing, but once a resource starts building,
we don't try to shut it down if what it depends on starts crashing.

It's possible to replicate this extension's functionality on the command line
using the `jq` utility to parse Tilt's engine state. 

1. find each resource's dependencies
```
$ tilt dump engine | jq '.ManifestTargets[].Manifest | { name:.Name , deps:.ResourceDependencies } '
```
2. find each resource's status
```
$ tilt dump engine | jq '.ManifestTargets[] | { resource_name:.Manifest.Name, pods:.State.RuntimeState.Pods } | .pods["\(.resource_name)"].containers[].ready'
```

This extension requires `python3` and its `subprocess` and `json` libraries.
