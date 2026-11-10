# Read-back of the objects a helm release just applied, retried on NotFound.
#
# Controllers may delete/recreate an object right after helm creates it (e.g.
# vCluster's service syncer, to fix an immutable spec.clusterIP). A `kubectl get`
# landing in that gap fails for an object that exists a moment later.

import subprocess
import time

DEFAULT_ATTEMPTS = 5
DEFAULT_DELAY_SECONDS = 1.0


def is_transient_not_found(stderr: str) -> bool:
  return 'NotFound' in stderr


def run_readback(cmd, input_bytes, attempts=DEFAULT_ATTEMPTS,
                 delay=DEFAULT_DELAY_SECONDS, runner=subprocess.run,
                 sleeper=time.sleep, log=None):
  """Run `cmd`, retrying while it fails with NotFound.

  Returns the last CompletedProcess. Output is captured, not inherited, so a
  failed attempt's partial object list never reaches Tilt.
  """
  attempts = max(1, attempts)
  for attempt in range(1, attempts + 1):
    completed = runner(cmd, input=input_bytes,
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if completed.returncode == 0:
      return completed

    stderr = completed.stderr.decode('utf-8', 'replace')
    if not is_transient_not_found(stderr) or attempt == attempts:
      return completed

    if log:
      log('read-back attempt %d/%d hit NotFound, retrying in %ss: %s'
          % (attempt, attempts, delay, stderr.strip()))
    sleeper(delay)


def attempts_from_env(env):
  return int(env.get('TILT_HELM_READBACK_ATTEMPTS', DEFAULT_ATTEMPTS))


def delay_from_env(env):
  return float(env.get('TILT_HELM_READBACK_DELAY_SECONDS',
                       DEFAULT_DELAY_SECONDS))
