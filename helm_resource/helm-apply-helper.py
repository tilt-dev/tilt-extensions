# Helper script for the Tiltfile's apply cmd. Not intended to be called independently.
#
# Usage:
# python3 helm-apply-helper.py ... [image config keys in order]

import json
import os
import subprocess
import sys
from typing import Dict

from fingerprint import fingerprint, flag_value
from namespacing import add_default_namespace

sys.tracebacklimit = 0

def _parse_image_string(image: str) -> Dict:
  if '.' in image or 'localhost' in image or image.count(":") > 1:
    registry, repository = image.split('/', 1)
    repository, tag = repository.rsplit(':', 1)
    return {"registry": registry, "repository": repository, "tag": tag}
  repository, tag = image.rsplit(':', 1)
  return {"registry": None, "repository": repository, "tag": tag}

def _deployed_description(release_name: str, namespace: str) -> str:
  """Return the description of the last revision if it is deployed, or an empty string."""
  history_cmd = ['helm', 'history', release_name, '--max', '1', '--output', 'json']
  if namespace:
    history_cmd.extend(['--namespace', namespace])

  print("Running cmd: %s" % history_cmd, file=sys.stderr)
  history = subprocess.run(history_cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
  if history.returncode != 0:
    return ''

  try:
    revisions = json.loads(history.stdout.decode('utf-8'))
  except ValueError:
    return ''
  if not revisions or revisions[-1].get('status') != 'deployed':
    return ''
  return revisions[-1].get('description', '')

def _read_back(manifest: str, namespace: str, kubectl_cmd):
  """Get the release objects from the cluster. Fail if an object is missing."""
  is_windows = True if os.name == 'nt' else False
  manifest_with_right_line_endings = manifest.replace(os.linesep, '\n') if is_windows else manifest
  input = add_default_namespace(manifest_with_right_line_endings, namespace).encode('utf-8')

  print("Running cmd: %s" % kubectl_cmd, file=sys.stderr)
  return subprocess.run(kubectl_cmd, input=input, stdout=subprocess.PIPE)

def _unchanged_objects(description: str, release_name: str, namespace: str, get_cmd, kubectl_cmd):
  """Return the objects of the release if it is up to date, or None if it needs an upgrade."""
  if _deployed_description(release_name, namespace) != description:
    return None

  print("Running cmd: %s" % get_cmd, file=sys.stderr)
  manifest = subprocess.run(get_cmd, stdout=subprocess.PIPE)
  if manifest.returncode != 0:
    return None

  completed = _read_back(manifest.stdout.decode('utf-8'), namespace, kubectl_cmd)
  if completed.returncode != 0:
    print("%s has missing objects, running the upgrade" % release_name, file=sys.stderr)
    return None
  return completed.stdout

flags = sys.argv[1:]

image_count = int(os.environ['TILT_IMAGE_COUNT'])
for i in range(image_count):
  image = os.environ['TILT_IMAGE_%s' % i]
  count = int(os.environ['TILT_IMAGE_KEY_COUNT_%s' % i])
  for j in range(count):
    suffix = '%s_%s' % (i, j)
    key = os.environ.get('TILT_IMAGE_KEY_%s' % suffix, '')
    if key:
      flags.extend(['--set', '%s=%s' % (key, image)])
      continue

    image_parts = _parse_image_string(image)
    key0 = os.environ.get('TILT_IMAGE_KEY_REGISTRY_%s' % suffix, '')
    key1 = os.environ.get('TILT_IMAGE_KEY_REPO_%s' % suffix, '')
    key2 = os.environ.get('TILT_IMAGE_KEY_TAG_%s' % suffix, '')

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

if os.environ.get('TILT_HELM_RELEASE_DEPENDENCY_UPDATE', False) == 'true':
  dependency_update_cmd = ['helm', 'dependency', 'update', chart]
  print("Running cmd: %s" % dependency_update_cmd, file=sys.stderr)
  subprocess.check_call(dependency_update_cmd, stdout=sys.stderr)

if os.environ.get('TILT_HELM_RELEASE_DEPENDENCY_BUILD', False) == 'true':
  dependency_build_cmd = ['helm', 'dependency', 'build', chart, '--skip-refresh']
  print("Running cmd: %s" % dependency_build_cmd, file=sys.stderr)
  subprocess.check_call(dependency_build_cmd, stdout=sys.stderr)

if os.environ.get('TILT_HELM_SKIP_UNCHANGED', False) == 'true':
  digest = fingerprint(chart, flags)
  if not digest:
    print("Tilt cannot digest the inputs of %s, running the upgrade" % release_name, file=sys.stderr)
  else:
    description = ' '.join(part for part in [flag_value(flags, '--description'), digest] if part)
    install_cmd.extend(['--description', description])

    objects = _unchanged_objects(description, release_name, namespace, get_cmd, kubectl_cmd)
    if objects is not None:
      print("%s is unchanged, skipping the upgrade" % release_name, file=sys.stderr)
      sys.stdout.buffer.write(objects)
      sys.exit(0)

print("Running cmd: %s" % install_cmd, file=sys.stderr)
subprocess.check_call(install_cmd, stdout=sys.stderr)

print("Running cmd: %s" % get_cmd, file=sys.stderr)
out = subprocess.check_output(get_cmd).decode('utf-8')

completed = _read_back(out, namespace, kubectl_cmd)
completed.check_returncode()
sys.stdout.buffer.write(completed.stdout)
