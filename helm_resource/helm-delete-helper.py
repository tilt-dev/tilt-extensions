# Helper script for the Tiltfile's delete cmd. Not intended to be called independently.
#
# Usage:
# python3 helm-delete-helper.py

import os
import subprocess
import sys

release_name = os.environ['RELEASE_NAME']
namespace = os.environ.get('NAMESPACE', '')
namespace_args = ('--namespace', namespace) if namespace else ()

# Check that release exists before uninstalling it
status_cmd = ('helm', 'status') + namespace_args + (release_name,)
status_result = subprocess.call(
  status_cmd,
  stdout=subprocess.DEVNULL,
  stderr=subprocess.DEVNULL,
)
if status_result == 0:
    delete_cmd = ('helm', 'uninstall') + namespace_args + (release_name,)
    print('Running cmd: %s' % ' '.join(delete_cmd), file=sys.stderr)
    subprocess.call(delete_cmd)
