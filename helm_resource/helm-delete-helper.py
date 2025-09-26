# Helper script for the Tiltfile's delete cmd. Not intended to be called independently.
#
# Usage:
# python3 helm-delete-helper.py

import os
import subprocess
import sys

k8s_context = os.environ["K8S_CONTEXT"]
release_name = os.environ['RELEASE_NAME']
namespace = os.environ.get('NAMESPACE', '')
namespace_args = ['--namespace', namespace] if namespace else []

flags = sys.argv[1:]

# Check that release exists before uninstalling it
status_cmd = ['helm', '--kube-context', k8s_context, 'status', release_name] + namespace_args
status_result = subprocess.call(
  status_cmd,
  stdout=subprocess.DEVNULL,
  stderr=subprocess.DEVNULL,
)
if status_result == 0:
    delete_cmd = ['helm', '--kube-context', k8s_context, 'uninstall', release_name] + namespace_args + flags
    print('Running cmd: %s' % ' '.join(delete_cmd), file=sys.stderr)
    subprocess.call(delete_cmd)
