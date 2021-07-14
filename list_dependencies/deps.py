#!/usr/bin/env python3
import subprocess
import json

def format_list(mylist):
    if len(mylist) < 2:
        return str(mylist)[1:-1]
    else:
        return str(mylist[:-1])[1:-1] + " and '" + str(mylist[-1]) + "'"

def get_node_info():
    stdout_str = subprocess.run(['tilt', 'dump', 'engine'], stdout=subprocess.PIPE).stdout.decode('utf-8')
    data = json.loads(stdout_str)["ManifestTargets"]

    dependencies = {}
    node_ready = {}

    for resInfo in data.values():
        manifest = resInfo["Manifest"]
        resName = manifest["Name"]
        resDeps = manifest["ResourceDependencies"]
        if resDeps == None:
            resDeps = []
        dependencies[resName] = resDeps

        pods = resInfo["State"]["RuntimeState"]["Pods"]
        if resName in pods:
            resStatus = pods[resName]["containers"][0]["ready"]
        else:
            resStatus = False
        node_ready[resName] = resStatus

    return (dependencies, node_ready)

def find_blocking(node, dependencies, ready):
    node_deps = dependencies[node]
    node_pending = []
    for i in node_deps:
        if not ready[i]:
            node_pending.append(i)
    return node_pending

def print_blocking(dependencies, ready):
    print("---- Resources waiting for dependencies ----")
    blocked_count = 0
    for node in dependencies.keys():
        blocking = find_blocking(node, dependencies, ready)
        if len(blocking) > 0:
            print("Resource '" + node + "' is blocking on " + format_list(blocking) + ".")
            blocked_count += 1
        # else:
        #     print("Resource '" + node + "' is not blocked by any dependencies.")

    if blocked_count == 0:
        print("No resources blocked at the moment.")
    print("--------------------------------------------")
    print()

(deps, ready) = get_node_info()
print_blocking(deps, ready)
