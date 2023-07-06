# Helper script for the Tiltfile's delete cmd. Not intended to be called independently.
#
# Usage:
# python3 helm-delete-helper.py

import os
import subprocess
import sys
import re

release_name = os.environ['RELEASE_NAME']
chart = os.environ['CHART']
namespace = os.environ.get('NAMESPACE', '')
namespace_args = ('--namespace', namespace) if namespace else ()

def extract_crd_names(docs):
  ## As PyYAML is not available, the commented code below is not usable.
  ## Using a fallback method using regexp.
  # resources = list(yaml.load_all(docs, Loader=yaml.SafeLoader))
  # crd_resources = filter(lambda r: r.kind == 'CustomResourceDefinition', resources)
  # return [r['metadata']['name'] for r in crd_resources]
  pattern = re.compile(r'\s*kind: CustomResourceDefinition.*?metadata:.*?\s+name: ([-\.a-z0-9]*)\n', re.DOTALL)
  crds = list(pattern.findall(docs))
  return crds

# Check that release exists before uninstalling it
status_cmd = ('helm', 'status') + namespace_args + (release_name,)
status_result = subprocess.call(
  status_cmd,
  stdout=subprocess.DEVNULL,
  stderr=subprocess.DEVNULL,
)
if status_result == 0:
    # Extract CRDs from managed manifests
    get_manifest_cmd = ('helm', 'get', 'manifest') + namespace_args + (release_name,)
    print('Running cmd: %s' % ' '.join(get_manifest_cmd), file=sys.stderr)
    raw_managed_resources = subprocess.check_output(get_manifest_cmd).decode(sys.stdout.encoding)
    crd_managed_names = extract_crd_names(raw_managed_resources)
  
    # Extract CRDs from pre-hook installed manifests
    show_crds_cmd = ('helm', 'show', 'crds', chart,)
    print('Running cmd: %s' % ' '.join(show_crds_cmd), file=sys.stderr)
    raw_prehook_crd_resources = subprocess.check_output(show_crds_cmd).decode(sys.stdout.encoding)
    crd_prehook_names = extract_crd_names(raw_prehook_crd_resources)

    # Remove all discovered CRDs
    crd_names = crd_managed_names + crd_prehook_names
    print('Found CRDs:', crd_names)
    for crd_name in crd_names:
        delete_cmd = ('kubectl', 'delete', 'crd', crd_name,)
        print('Running cmd: %s' % ' '.join(delete_cmd), file=sys.stderr)
        subprocess.call(delete_cmd)

    # Uninstall the chart
    delete_cmd = ('helm', 'uninstall') + namespace_args + (release_name,)
    print('Running cmd: %s' % ' '.join(delete_cmd), file=sys.stderr)
    subprocess.call(delete_cmd)
