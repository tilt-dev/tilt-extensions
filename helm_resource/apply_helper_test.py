import json
import os
import stat
import subprocess
import sys
import tempfile
import unittest

from fingerprint import fingerprint

HELPER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'helm-apply-helper.py')

# Logs each call. Answers `helm history` from $STUB_HISTORY and `helm get manifest` from
# $STUB_MANIFEST. `helm upgrade` replaces the manifest with a fresh one.
HELM = '''#!/bin/sh
echo "helm $*" >> "$STUB_LOG"
case "$1" in
  history) [ -f "$STUB_HISTORY" ] && cat "$STUB_HISTORY" || exit 1 ;;
  get) cat "$STUB_MANIFEST" ;;
  upgrade) printf 'kind: ConfigMap\\nmetadata:\\n  name: fresh\\n' > "$STUB_MANIFEST" ;;
esac
'''

# Logs each call and echoes the manifest back with a `uid` marker, like the live objects.
# Fails when the object $STUB_MISSING is in the manifest.
KUBECTL = '''#!/bin/sh
echo "kubectl $*" >> "$STUB_LOG"
input=$(cat)
if [ -n "$STUB_MISSING" ] && echo "$input" | grep -q "name: $STUB_MISSING"; then
  exit 1
fi
printf '%s\nuid: live\n' "$input"
'''


@unittest.skipIf(os.name == 'nt', 'the stubs are shell scripts')
class TestApplyHelper(unittest.TestCase):
  """Run the helper with stub `helm` and `kubectl` commands, without a cluster."""
  def setUp(self):
    directory = tempfile.TemporaryDirectory()
    self.addCleanup(directory.cleanup)
    self.root = directory.name
    self.chart = os.path.join(self.root, 'chart')
    os.makedirs(self.chart)
    with open(os.path.join(self.chart, 'Chart.yaml'), 'w') as f:
      f.write('name: chart')

    bin_dir = os.path.join(self.root, 'bin')
    os.makedirs(bin_dir)
    for name, script in [('helm', HELM), ('kubectl', KUBECTL)]:
      path = os.path.join(bin_dir, name)
      with open(path, 'w') as f:
        f.write(script)
      os.chmod(path, os.stat(path).st_mode | stat.S_IEXEC)

    self.log = os.path.join(self.root, 'log')
    self.history = os.path.join(self.root, 'history.json')
    self.manifest = os.path.join(self.root, 'manifest.yaml')
    self.env = dict(
      os.environ,
      PATH=bin_dir + os.pathsep + os.environ['PATH'],
      STUB_LOG=self.log,
      STUB_HISTORY=self.history,
      STUB_MANIFEST=self.manifest,
      TILT_IMAGE_COUNT='0',
      RELEASE_NAME='release',
      CHART=self.chart,
      TILT_HELM_SKIP_UNCHANGED='true',
    )

  def deploy(self, status, description=None, manifest='kind: ConfigMap\nmetadata:\n  name: stored\n'):
    """Set the last revision and the manifest that the stub `helm` returns."""
    revision = {'status': status}
    if description is not None:
      revision['description'] = description
    with open(self.history, 'w') as f:
      json.dump([revision], f)
    with open(self.manifest, 'w') as f:
      f.write(manifest)

  def run_helper(self, *flags):
    """Run the helper with the given flags. Return its output and the stub calls it made."""
    open(self.log, 'w').close()
    completed = subprocess.run(
      [sys.executable, HELPER] + list(flags), env=self.env,
      stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    with open(self.log) as f:
      calls = f.read().splitlines()
    return completed.stdout.decode('utf-8'), calls

  def upgrades(self, calls):
    return [call for call in calls if call.startswith('helm upgrade')]

  def test_no_release(self):
    """Without a release, Tilt installs it and stores the digest."""
    _, calls = self.run_helper()
    self.assertEqual(1, len(self.upgrades(calls)))
    self.assertIn('--description tilt:', self.upgrades(calls)[0])

  def test_unchanged(self):
    """When nothing changed, Tilt skips the upgrade and returns the live objects."""
    self.deploy('deployed', fingerprint(self.chart, []))
    out, calls = self.run_helper()
    self.assertEqual([], self.upgrades(calls))
    self.assertIn('name: stored', out)
    self.assertIn('uid: live', out)

  def test_digest_comes_last(self):
    """Tilt's description comes after the user's one, so helm keeps Tilt's."""
    _, calls = self.run_helper('--description', 'mine')
    last_description = self.upgrades(calls)[0].rsplit('--description ', 1)[1]
    self.assertTrue(last_description.startswith('mine tilt:'))

  def test_namespace(self):
    """Tilt reads the release and its objects in the namespace of the resource."""
    self.env['NAMESPACE'] = 'ns'
    self.deploy('deployed', fingerprint(self.chart, []))
    out, calls = self.run_helper()
    self.assertIn('helm history release --max 1 --output json --namespace ns', calls)
    self.assertIn('namespace: ns', out)

  def test_image(self):
    """A new image triggers an upgrade, and the same image does not."""
    self.env.update(
      TILT_IMAGE_COUNT='1',
      TILT_IMAGE_0='repo/image:new',
      TILT_IMAGE_KEY_COUNT_0='1',
      TILT_IMAGE_KEY_0_0='image',
    )
    self.deploy('deployed', fingerprint(self.chart, ['--set', 'image=repo/image:old']))
    _, calls = self.run_helper()
    self.assertEqual(1, len(self.upgrades(calls)))

    self.deploy('deployed', fingerprint(self.chart, ['--set', 'image=repo/image:new']))
    _, calls = self.run_helper()
    self.assertEqual([], self.upgrades(calls))

  def test_user_description(self):
    """Tilt keeps the user's description and still skips the upgrade."""
    self.deploy('deployed', 'mine %s' % fingerprint(self.chart, ['--description', 'mine']))
    _, calls = self.run_helper('--description', 'mine')
    self.assertEqual([], self.upgrades(calls))

  def test_changed(self):
    """A changed flag triggers an upgrade."""
    self.deploy('deployed', fingerprint(self.chart, []))
    _, calls = self.run_helper('--set', 'a=b')
    self.assertEqual(1, len(self.upgrades(calls)))

  def test_missing_object(self):
    """A deleted object triggers an upgrade that restores it."""
    self.deploy('deployed', fingerprint(self.chart, []))
    self.env['STUB_MISSING'] = 'stored'
    out, calls = self.run_helper()
    self.assertEqual(1, len(self.upgrades(calls)))
    self.assertIn('name: fresh', out)

  def test_failed_release(self):
    """A failed release triggers an upgrade, even with a matching digest."""
    self.deploy('failed', fingerprint(self.chart, []))
    _, calls = self.run_helper()
    self.assertEqual(1, len(self.upgrades(calls)))

  def test_empty_manifest(self):
    """A release without objects can skip the upgrade."""
    self.deploy('deployed', fingerprint(self.chart, []), manifest='')
    _, calls = self.run_helper()
    self.assertEqual([], self.upgrades(calls))

  def test_invalid_history(self):
    """An unreadable `helm history` output triggers an upgrade."""
    with open(self.history, 'w') as f:
      f.write('not json')
    _, calls = self.run_helper()
    self.assertEqual(1, len(self.upgrades(calls)))

  def test_undigestible_input(self):
    """An input that Tilt cannot digest triggers an upgrade without a digest."""
    _, calls = self.run_helper('--set-file', 'a=a.txt')
    self.assertEqual(1, len(self.upgrades(calls)))
    self.assertNotIn('tilt:', self.upgrades(calls)[0])

  def test_disabled(self):
    """Without the option, Tilt always upgrades and does not read the release."""
    del self.env['TILT_HELM_SKIP_UNCHANGED']
    self.deploy('deployed', fingerprint(self.chart, []))
    _, calls = self.run_helper()
    self.assertNotIn('helm history', ' '.join(calls))
    self.assertEqual(1, len(self.upgrades(calls)))


if __name__ == '__main__':
  unittest.main()
