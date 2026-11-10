import unittest

from readback import (
  attempts_from_env,
  delay_from_env,
  is_transient_not_found,
  run_readback,
)


class FakeCompleted:
  def __init__(self, returncode, stdout=b'', stderr=b''):
    self.returncode = returncode
    self.stdout = stdout
    self.stderr = stderr


class FakeRunner:
  def __init__(self, results):
    self.results = list(results)
    self.calls = []

  def __call__(self, cmd, input=None, stdout=None, stderr=None):
    self.calls.append((cmd, input))
    return self.results.pop(0)


NOT_FOUND = FakeCompleted(
  1, stdout=b'apiVersion: v1\nitems: []\n',
  stderr=b'Error from server (NotFound): services "my-svc" not found\n')
OK = FakeCompleted(0, stdout=b'apiVersion: v1\nkind: List\n')
FORBIDDEN = FakeCompleted(
  1, stderr=b'Error from server (Forbidden): services "my-svc" is forbidden\n')


class TestRunReadback(unittest.TestCase):
  def run_with(self, results, attempts=5):
    runner = FakeRunner(results)
    slept = []
    completed = run_readback(['kubectl', 'get'], b'manifest',
                             attempts=attempts, delay=0.5, runner=runner,
                             sleeper=slept.append)
    return completed, runner, slept

  def test_succeeds_first_try_without_sleeping(self):
    completed, runner, slept = self.run_with([OK])
    self.assertEqual(0, completed.returncode)
    self.assertEqual(1, len(runner.calls))
    self.assertEqual([], slept)

  def test_retries_not_found_until_it_succeeds(self):
    completed, runner, slept = self.run_with([NOT_FOUND, NOT_FOUND, OK])
    self.assertEqual(0, completed.returncode)
    self.assertEqual(3, len(runner.calls))
    self.assertEqual([0.5, 0.5], slept)

  def test_gives_up_after_attempts_and_returns_the_failure(self):
    completed, runner, slept = self.run_with([NOT_FOUND] * 3, attempts=3)
    self.assertEqual(1, completed.returncode)
    self.assertEqual(3, len(runner.calls))
    self.assertEqual([0.5, 0.5], slept, 'must not sleep after the last try')

  def test_does_not_retry_other_errors(self):
    completed, runner, slept = self.run_with([FORBIDDEN, OK])
    self.assertEqual(1, completed.returncode)
    self.assertEqual(1, len(runner.calls))
    self.assertEqual([], slept)

  def test_non_positive_attempts_still_runs_once(self):
    completed, runner, slept = self.run_with([OK], attempts=0)
    self.assertEqual(0, completed.returncode)
    self.assertEqual(1, len(runner.calls))

  def test_feeds_the_same_manifest_to_every_attempt(self):
    _, runner, _ = self.run_with([NOT_FOUND, OK])
    self.assertEqual([b'manifest', b'manifest'],
                     [call[1] for call in runner.calls])


class TestNotFoundDetection(unittest.TestCase):
  def test_matches_kubectl_not_found(self):
    self.assertTrue(is_transient_not_found(
      'Error from server (NotFound): services "my-svc" not found'))

  def test_ignores_unrelated_errors(self):
    self.assertFalse(is_transient_not_found('connection refused'))


class TestEnvOverrides(unittest.TestCase):
  def test_defaults(self):
    self.assertEqual(5, attempts_from_env({}))
    self.assertEqual(1.0, delay_from_env({}))

  def test_overrides(self):
    self.assertEqual(9, attempts_from_env(
      {'TILT_HELM_READBACK_ATTEMPTS': '9'}))
    self.assertEqual(0.25, delay_from_env(
      {'TILT_HELM_READBACK_DELAY_SECONDS': '0.25'}))


if __name__ == '__main__':
  unittest.main()
