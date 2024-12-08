#!/usr/bin/env python3
import json
import subprocess


def format_list(mylist):
    if len(mylist) < 2:
        return str(mylist)[1:-1]
    else:
        return str(mylist[:-1])[1:-1] + " and '" + str(mylist[-1]) + "'"

def get_node_dependencies():
    node_str = subprocess.run(
            ['tilt', 'dump', 'engine'],
            stdout=subprocess.PIPE,
        ).stdout.decode('utf-8')
    node_data = json.loads(node_str)["ManifestTargets"]

    dependencies = {}

    for resInfo in node_data.values():
        manifest = resInfo["Manifest"]
        resName = manifest["Name"]
        resDeps = manifest["ResourceDependencies"]
        if resDeps is None:
            resDeps = []
        dependencies[resName] = resDeps

    return dependencies

def get_node_status():
    ready_str = subprocess.run(
            ['tilt', 'get', 'kubernetesdiscovery', '-o', 'json'],
            stdout=subprocess.PIPE,
        ).stdout.decode('utf-8')
    ready_data = json.loads(ready_str)["items"]

    ready = {}

    for resInfo in ready_data:
        resName = resInfo["metadata"]["name"]
        pods = resInfo["status"]["pods"]
        resStatus = False
        if pods is not None:
            for pod in pods:
                containers = pod["containers"]
                for container in containers:
                    resStatus = container["ready"]
        ready[resName] = resStatus

    return ready

def keys_same(mapA, mapB):
    return mapA.keys() == mapB.keys()

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

deps = get_node_dependencies()
ready = get_node_status()
if not keys_same(deps, ready):
    print("Mismatched dependency and status information -- please retry")
else:
    print_blocking(deps, ready)
