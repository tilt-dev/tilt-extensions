# Helper script for the Tiltfile's delete cmd. Not intended to be called independently.
#
# Usage:
# python3 helm-delete-helper.py

import os
import subprocess
import sys

delete_cmd = ['helm', 'uninstall']
namespace = os.environ.get('NAMESPACE', '')
if namespace:
  delete_cmd.extend(['--namespace', namespace])

delete_cmd.extend([os.environ['RELEASE_NAME']])

# ignore error code.
print("Running cmd: %s" % delete_cmd, file=sys.stderr)
subprocess.call(delete_cmd)
