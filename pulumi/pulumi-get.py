# Export all the deployed resources from the current Pulumi stack.
#
# Usage:
# python3 pulumi-get.py [stack]

import json
import subprocess
import sys

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

  o = resource.get('outputs', [])
  kind = o.get('kind', '').lower()
  name = o.get('metadata', {}).get('name', '')
  if kind and name:
    print(subprocess.check_output(['kubectl', 'get', kind, name, '-o=yaml']).decode('utf-8'))
    print('---')
