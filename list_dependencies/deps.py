#!/usr/bin/env python3
import subprocess
import json

class Resource:
    def __init__(self, name, status, deps):
        self.name = name
        self.status = status
        self.deps = deps

    def __str__():
        return str(name) + str(status) + str(deps)

# replicate the following:
# 1. find dependencies
# $ tilt dump engine | jq '.ManifestTargets[].Manifest | { name:.Name , deps:.ResourceDependencies } '
# 2. find status
# $ tilt dump engine | jq '.ManifestTargets[] | { resource_name:.Manifest.Name, pods:.State.RuntimeState.Pods } | .pods["\(.resource_name)"].containers[].ready'

stdout_str = subprocess.run(['tilt', 'dump', 'engine'], stdout=subprocess.PIPE).stdout.decode('utf-8')
data = json.loads(stdout_str)["ManifestTargets"]

# construct a forward graph given the output

g_f = {}
node_ready = {}

for resInfo in data.values():
    manifest = resInfo["Manifest"]
    resName = manifest["Name"]
    resDeps = manifest["ResourceDependencies"]
    if resDeps == None:
        resDeps = []
    g_f[resName] = resDeps

    pods = resInfo["State"]["RuntimeState"]["Pods"]
    if resName in pods:
        resStatus = pods[resName]["containers"][0]["ready"]
    else:
        resStatus = False
    node_ready[resName] = resStatus

print(g_f)
print(node_ready)

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

# find blocking

def find_blocking(node):
    deps = g_f[node]
    pending = []
    for i in deps:
        if not node_ready[i]:
            pending.append(i)
    return pending

def format_list(mylist):
    return str(mylist)[1:-1]

for node in g_r.keys():
    blocking = find_blocking(node)
    if len(blocking) > 0:
        print("Resource \"" + node + "\" is blocking on " + format_list(blocking))
    else:
        print("Resource \"" + node + "\" is not blocked by any dependencies.")

