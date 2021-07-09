#!/usr/bin/env python3
import subprocess
import json

# replicate the following:
# $ tilt dump engine | jq '.ManifestTargets[].Manifest | { name:.Name , deps:.ResourceDependencies } '

stdout_str = subprocess.run(['tilt', 'dump', 'engine'], stdout=subprocess.PIPE).stdout.decode('utf-8')
data = json.loads(stdout_str)

# construct a forward graph given the output

g_f = {}

for resInfo in data["ManifestTargets"].values():
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
