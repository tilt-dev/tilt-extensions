## List resources being blocked by dependencies

A simple extension that displays a list of which resources are being blocked by dependencies,
as well as the specific dependencies they are waiting for, 
via a UI button on the (Tiltfile) resource.

It is also possible to do this on the command line using the `jq` utility to parse Tilt's engine state. 
1. find each resource's dependencies
```$ tilt dump engine | jq '.ManifestTargets[].Manifest | { name:.Name , deps:.ResourceDependencies } '```
2. find each resource's status
```$ tilt dump engine | jq '.ManifestTargets[] | { resource_name:.Manifest.Name, pods:.State.RuntimeState.Pods } | .pods["\(.resource_name)"].containers[].ready'```

This extension requires `python3` and its `subprocess` and `json` libraries.
