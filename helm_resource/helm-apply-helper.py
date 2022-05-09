# Helper script for the Tiltfile's apply cmd. Not intended to be called independently.
#
# Usage:
# python3 helm-apply-helper.py ... [image config keys in order]

import os
import re
import subprocess
import sys
from typing import Dict

def _parse_image_string(image: str) -> Dict:
  if '.' in image or 'localhost' in image or image.count(":") > 1:
    registry, repository = image.split('/', 1)
    repository, tag = repository.rsplit(':', 1)
    return {"registry": registry, "repository": repository, "tag": tag}
  repository, tag = image.rsplit(':', 1)
  return {"registry": None, "repository": repository, "tag": tag}

flags = sys.argv[1:]

image_count = int(os.environ['TILT_IMAGE_COUNT'])
for i in range(image_count):
  image = os.environ['TILT_IMAGE_%s' % i]
  key = os.environ.get('TILT_IMAGE_KEY_%s' % i, '')
  if key:
    flags.extend(['--set', '%s=%s' % (key, image)])
    continue

  image_parts = _parse_image_string(image)
  key0 = os.environ.get('TILT_IMAGE_KEY_REGISTRY_%s' % i, '')
  key1 = os.environ.get('TILT_IMAGE_KEY_REPO_%s' % i, '')
  key2 = os.environ.get('TILT_IMAGE_KEY_TAG_%s' % i, '') 

  if image_parts['registry']: 
    if key0 != '':
      # Image has a registry AND a specific helm key for the registry
      flags.extend(['--set', '%s=%s' % (key0, image_parts["registry"]),
                    '--set', '%s=%s' % (key1, image_parts["repository"])])
    else:
      # Image has a registry but does not have a specific helm key for registry
      flags.extend(['--set', '%s=%s/%s' % (key1, image_parts["registry"], image_parts["repository"])])
  else:
    # Image does NOT have a registry component
    flags.extend(['--set', '%s=%s' % (key1, image_parts["repository"])])
  flags.extend(['--set', '%s=%s' % (key2, image_parts["tag"])])

install_cmd = ['helm', 'upgrade', '--install']
install_cmd.extend(flags)

get_cmd = ['helm', 'get', 'manifest']
kubectl_cmd = ['kubectl', 'get']

release_name = os.environ['RELEASE_NAME']
chart = os.environ['CHART']
namespace = os.environ.get('NAMESPACE', '')
if namespace:
  install_cmd.extend(['--namespace', namespace])
  get_cmd.extend(['--namespace', namespace])

install_cmd.extend([release_name, chart])
get_cmd.extend([release_name])
kubectl_cmd.extend(['-oyaml', '-f', '-'])

print("Running cmd: %s" % install_cmd, file=sys.stderr)
subprocess.check_call(install_cmd, stdout=sys.stderr)

print("Running cmd: %s" % get_cmd, file=sys.stderr)
out = subprocess.check_output(get_cmd).decode('utf-8')

# We have to do namespace defaulting ourselves :(
# See: https://github.com/tilt-dev/tilt-extensions/issues/374
def add_default_namespace(yaml, namespace):
  if not namespace:
    return yaml

  resources = re.split('^---$', yaml, flags=re.MULTILINE)

  for i in range(len(resources)):
    r = resources[i]

    # Find the part of the yaml that has the metadata: and following indented lines.
    meta = re.search("^(metadata:\n(\\s+.*\n)*)", r, re.MULTILINE)
    if not meta:
      continue

    metadata = meta.group(0)

    # Remove empty namespace blocks.
    metadata = re.sub("\n\\s+namespace:\\s*\n", "\n", metadata, flags=re.MULTILINE)

    has_namespace = re.search("\n\\s+namespace: *\\S", metadata, re.MULTILINE)
    if not has_namespace:
      metadata = metadata.replace(
        "\nmetadata:",
        "\nmetadata:\n  namespace: %s" % namespace, 1)
      resources[i] = r[0:meta.start()] + metadata + r[meta.end():]

  return '---'.join(resources)

print("Running cmd: %s" % kubectl_cmd, file=sys.stderr)
completed = subprocess.run(
  kubectl_cmd,
  input=add_default_namespace(out, namespace).encode('utf-8'))
completed.check_returncode()
