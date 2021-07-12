#!/usr/bin/env python3
import subprocess
import json

# replicate the following:
# $ tilt dump engine | jq '.ManifestTargets[].Manifest | { name:.Name , deps:.ResourceDependencies } '

stdout_str = subprocess.run(['tilt', 'dump', 'engine'], stdout=subprocess.PIPE).stdout.decode('utf-8')
data = json.loads(stdout_str)["ManifestTargets"]

# construct a forward graph given the output

g_f = {}

for resInfo in data.values():
    manifest = resInfo["Manifest"]
    resName = manifest["Name"]
    resDeps = manifest["ResourceDependencies"]
    g_f[resName] = resDeps

# construct the reverse graph

g_r = {}

for nodeName in g_f.keys():
    # init each row
    g_r[nodeName] = []

for (start, neighbors) in g_f.items():
    if neighbors != None:
        for end in neighbors:
            g_r[end].append(start)

print(g_r)

# now what?
# find which of these resources are unbuilt.

# command to replicate:
# tilt dump engine | jq '.ManifestTargets[] | { resource_name:.Manifest.Name, pods:.State.RuntimeState.Pods } | .pods["\(.resource_name)"].containers[].ready'

for resInfo in data.values():
    resource_name = resInfo["Manifest"]["Name"]
    pods = resInfo["State"]["RuntimeState"]["Pods"]
    resStatus = pods[resource_name]["containers"][0]["ready"]
    print(resStatus)

