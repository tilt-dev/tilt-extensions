"""Detect whether a helm release needs an upgrade."""

import csv
import hashlib
import os
from typing import List, Optional

# Flags that make helm read an input this module cannot digest.
UNDIGESTIBLE_FLAGS = ('--set-file', '--post-renderer', '--post-renderer-args')

def flag_values(flags, name: str, shorthand: str = '') -> List[str]:
  """Return every value of a flag, in order.

  Handle `--flag value`, `--flag=value` and, for a short flag, `-f value`, `-f=value` and
  `-fvalue`.
  """
  values = []
  i = 0
  while i < len(flags):
    flag = flags[i]
    if (flag == name or (shorthand and flag == shorthand)) and i + 1 < len(flags):
      values.append(flags[i + 1])
      i += 2
      continue
    if flag.startswith(name + '='):
      values.append(flag[len(name) + 1:])
    elif shorthand and flag.startswith(shorthand) and flag != shorthand:
      value = flag[len(shorthand):]
      values.append(value[1:] if value.startswith('=') else value)
    i += 1
  return values

def flag_value(flags, name: str) -> str:
  """Return the last value of a flag, or an empty string."""
  values = flag_values(flags, name)
  return values[-1] if values else ''

def values_files(flags) -> List[str]:
  """Return the paths of the values files passed to helm."""
  paths = []
  # `--values` is a string slice: helm splits each value as a CSV record.
  for value in flag_values(flags, '--values', '-f'):
    paths.extend(next(csv.reader([value])))
  return paths

def _update(digest, data: bytes):
  """Add a length-prefixed chunk to the digest."""
  digest.update(b'%d\0' % len(data))
  digest.update(data)

def _raise(error):
  """Make os.walk() fail on a directory it cannot read."""
  raise error

def _digest_path(digest, path: str):
  """Add a file, or all the files in a directory, to the digest. Follow symlinks."""
  if os.path.isdir(path):
    for parent, dirs, names in os.walk(path, onerror=_raise, followlinks=True):
      dirs.sort()
      for name in sorted(names):
        _digest_path(digest, os.path.join(parent, name))
    return

  # open() would block on a FIFO.
  if not os.path.isfile(path):
    raise OSError('not a regular file: %s' % path)
  _update(digest, os.fsencode(path))
  with open(path, 'rb') as contents:
    _update(digest, contents.read())

def _may_hide_values_flag(flag: str) -> bool:
  """Return True when a group of short flags, such as `-if values.yaml`, may contain `-f`."""
  return len(flag) > 2 and flag.startswith('-') and not flag.startswith(('--', '-f')) and 'f' in flag

def _fingerprint(chart: str, flags) -> Optional[str]:
  """Compute the digest. Raise an error when an input cannot be read."""
  for flag in flags:
    if flag in UNDIGESTIBLE_FLAGS or flag.startswith(tuple(f + '=' for f in UNDIGESTIBLE_FLAGS)):
      return None
    if _may_hide_values_flag(flag):
      return None

  paths = values_files(flags)
  # `-` is stdin, and helm downloads a value with a URL scheme.
  if any(path.strip() == '-' or '://' in path for path in paths):
    return None

  digest = hashlib.sha256()
  _update(digest, os.fsencode(chart))
  _update(digest, b'%d' % len(flags))
  for flag in flags:
    _update(digest, os.fsencode(flag))

  # Like helm, ignore the spaces around a local chart path.
  if os.path.exists(chart.strip()):
    paths.append(chart.strip())
  for path in paths:
    _digest_path(digest, path)

  return 'tilt:%s' % digest.hexdigest()[:12]

def fingerprint(chart: str, flags) -> Optional[str]:
  """Compute a digest of the inputs that change what helm installs.

  Return None if an input cannot be digested.
  """
  try:
    return _fingerprint(chart, flags)
  except (OSError, ValueError, csv.Error):
    return None
