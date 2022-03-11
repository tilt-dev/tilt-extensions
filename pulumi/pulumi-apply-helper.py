# Helper script for the Tiltfile's apply cmd. Not intended to be called independently.
#
# Usage:
# python3 pulumi-apply-helper.py ... [image config keys in order]

import os
import subprocess
import sys

stack = os.environ.get('STACK', '')
extension_dir = os.path.dirname(sys.argv[0])
image_configs = sys.argv[1:]

apply_cmd = ['pulumi', 'up', '--refresh', '-y']
for i in range(len(image_configs)):
  config = image_configs[i]
  image = os.environ['TILT_IMAGE_%s' % i]
  apply_cmd.extend(['--config', '%s=%s' % (config, image)])

get_cmd = ['python3', os.path.join(extension_dir, 'pulumi-get.py')]
if stack:
  apply_cmd.extend(['--stack', stack])
  get_cmd.extend([stack])

subprocess.check_call(apply_cmd, stdout=sys.stderr)
subprocess.check_call(get_cmd)
