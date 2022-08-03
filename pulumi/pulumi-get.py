# Export all the deployed resources from the current Pulumi stack.
#
# Usage:
# python3 pulumi-get.py [stack]

import json
import subprocess
import sys

helmResourceKindMap = {
  'ConfigMap/v1': 'configmaps',
  'Deployment.apps/apps/v1': 'deployments',
  'Secret/v1': 'secrets',
  'Service/v1': 'services',
  'ServiceAccount/v1': 'serviceaccounts',
  'StatefulSets.apps/apps/v1': 'statefulsets',
}

def dumpResource(ns, kind, name):
  if kind and name:
    args = ['kubectl', 'get']
    if ns:
      args.extend(['-n', ns])
    
    args.extend([kind, name, '-o=yaml'])
    print(subprocess.check_output(args).decode('utf-8'))
    print('---')

export_cmd = ['pulumi', 'stack', 'export']
if len(sys.argv) >= 2:
  export_cmd.extend(['-s', sys.argv[1]])

stack_json = subprocess.check_output(export_cmd)
stack = json.loads(stack_json)
resources = stack.get('deployment', {}).get('resources', [])
for resource in resources:
  t = resource.get('type', '')
  is_k8s = isinstance(t, str) and t.find('kubernetes:') == 0
  if not is_k8s:
    continue
  
  o = resource.get('outputs', {})

  if t.find('kubernetes:helm.sh/') == 0:
    if t == 'kubernetes:helm.sh/v3:Release':
      helmResources = o.get('resourceNames', {})
      for helmResourceKind in helmResources:
        if helmResourceKind in helmResourceKindMap:
          kind = helmResourceKindMap[helmResourceKind]
          for helmResource in helmResources[helmResourceKind]:
            ns = isinstance(o.get('namespace', ''), str) and o.get('namespace', '')
            name = helmResource
            if helmResource.find('/') > 0:
              ns = helmResource[0:helmResource.find('/')]
              name = helmResource[helmResource.find('/') + 1:len(helmResource)]
            
            dumpResource(ns, kind, name)
  else:
    if not o.get('kind', ''):
      continue

    kind = o.get('kind', '').lower()
    name = o.get('metadata', {}).get('name', '')
    ns = o.get('metadata', {}).get('namespace', '')
    dumpResource(ns, kind, name)
