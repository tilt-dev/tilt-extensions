import os
import tempfile
import unittest

from fingerprint import fingerprint, flag_value, values_files


class TestValuesFiles(unittest.TestCase):
  def test_long_flag(self):
    """Finds the values files passed with `--values file` and `--values=file`."""
    self.assertEqual(['a.yaml', 'b.yaml'], values_files(['--values', 'a.yaml', '--values=b.yaml']))

  def test_short_flag(self):
    """Finds the values files passed with `-f file`, `-f=file` and `-ffile`."""
    self.assertEqual(['a.yaml', 'b.yaml', 'c.yaml'], values_files(['-f', 'a.yaml', '-f=b.yaml', '-fc.yaml']))

  def test_comma_separated(self):
    """Splits a comma-separated list of values files, like helm."""
    self.assertEqual(['a.yaml', 'b.yaml'], values_files(['-f', 'a.yaml,b.yaml']))

  def test_quoted_comma(self):
    """Keeps a quoted comma in a values file name, like helm."""
    self.assertEqual(['a,b.yaml'], values_files(['-f', '"a,b.yaml"']))

  def test_other_flags(self):
    """Ignores the flags that are not `--values`."""
    self.assertEqual([], values_files(['--set', 'f=x', '--force']))


class TestFlagValue(unittest.TestCase):
  def test_missing(self):
    """Returns an empty string for a missing flag."""
    self.assertEqual('', flag_value(['--set', 'a=b'], '--description'))

  def test_last_value_wins(self):
    """Returns the last value of a repeated flag, like helm."""
    self.assertEqual('second', flag_value(['--description', 'first', '--description=second'], '--description'))


class TestFingerprint(unittest.TestCase):
  def setUp(self):
    directory = tempfile.TemporaryDirectory()
    self.addCleanup(directory.cleanup)
    self.root = directory.name
    self.chart = os.path.join(self.root, 'chart')
    os.makedirs(os.path.join(self.chart, 'templates'))
    self.write('chart/Chart.yaml', 'name: chart')
    self.write('values.yaml', 'a: 1')

  def write(self, path, contents):
    with open(os.path.join(self.root, path), 'w') as f:
      f.write(contents)

  def test_stable(self):
    """The same inputs give the same digest."""
    flags = ['-f', os.path.join(self.root, 'values.yaml')]
    self.assertEqual(fingerprint(self.chart, flags), fingerprint(self.chart, flags))

  def test_flags(self):
    """A changed flag changes the digest."""
    self.assertNotEqual(fingerprint(self.chart, ['--set', 'a=1']), fingerprint(self.chart, ['--set', 'a=2']))

  def test_values_file(self):
    """A changed values file changes the digest."""
    flags = ['-f%s' % os.path.join(self.root, 'values.yaml')]
    before = fingerprint(self.chart, flags)
    self.write('values.yaml', 'a: 2')
    self.assertNotEqual(before, fingerprint(self.chart, flags))

  def test_chart(self):
    """A changed local chart changes the digest."""
    before = fingerprint(self.chart, [])
    self.write('chart/templates/cm.yaml', 'kind: ConfigMap')
    self.assertNotEqual(before, fingerprint(self.chart, []))

  def test_chart_path_with_spaces(self):
    """A local chart path with spaces around it is still digested."""
    before = fingerprint(self.chart + ' ', [])
    self.write('chart/templates/cm.yaml', 'kind: ConfigMap')
    self.assertNotEqual(before, fingerprint(self.chart + ' ', []))

  def test_symlinked_directory(self):
    """A change in a symlinked directory of the chart changes the digest."""
    os.makedirs(os.path.join(self.root, 'linked'))
    try:
      os.symlink(os.path.join(self.root, 'linked'), os.path.join(self.chart, 'templates', 'linked'))
    except OSError:
      self.skipTest('cannot create a symlink')
    before = fingerprint(self.chart, [])
    self.write('linked/cm.yaml', 'kind: ConfigMap')
    self.assertNotEqual(before, fingerprint(self.chart, []))

  def test_no_collision(self):
    """Moving bytes from one file to another changes the digest."""
    self.write('chart/a', 'X')
    self.write('chart/b', 'Y')
    before = fingerprint(self.chart, [])
    os.remove(os.path.join(self.chart, 'b'))
    self.write('chart/a', 'X' + os.path.join(self.chart, 'b') + 'Y')
    self.assertNotEqual(before, fingerprint(self.chart, []))

  def test_non_utf8_file_name(self):
    """A file name that is not valid UTF-8 does not prevent the digest."""
    try:
      with open(os.path.join(os.fsencode(self.chart), b'caf\xe9.yaml'), 'w') as f:
        f.write('a: 1')
    except OSError:
      self.skipTest('the file system rejects non-UTF-8 file names')
    self.assertIsNotNone(fingerprint(self.chart, []))

  @unittest.skipUnless(hasattr(os, 'mkfifo'), 'no FIFO on this platform')
  def test_fifo(self):
    """A FIFO in the chart prevents the digest instead of blocking."""
    os.mkfifo(os.path.join(self.chart, 'fifo'))
    self.assertIsNone(fingerprint(self.chart, []))

  def test_remote_chart(self):
    """A remote chart is digested by its reference."""
    self.assertEqual(fingerprint('repo/a', []), fingerprint('repo/a', []))
    self.assertNotEqual(fingerprint('repo/a', []), fingerprint('repo/b', []))

  def test_undigestible_inputs(self):
    """An input that Tilt cannot digest prevents the digest."""
    # Create the files, so that these cases do not pass only because a file is missing.
    cwd = os.getcwd()
    os.chdir(self.root)
    self.addCleanup(os.chdir, cwd)
    os.makedirs('https:/example.com')
    for path in ['-', ' -', 'https:/example.com/values.yaml']:
      self.write(path, 'a: 1')

    for flags in [
      ['--set-file', 'a=values.yaml'],
      ['--set-file=a=values.yaml'],
      ['--post-renderer', 'plugin'],
      ['--post-renderer=plugin'],
      ['--post-renderer-args', 'arg'],
      ['-f', 'https://example.com/values.yaml'],
      ['-f', '-'],
      ['-f', ' -'],
      ['-if', 'values.yaml'],
    ]:
      with self.subTest(flags=flags):
        self.assertIsNone(fingerprint(self.chart, flags))

  def test_value_that_looks_like_a_flag(self):
    """A flag value that looks like `-f` does not crash."""
    self.assertIsNone(fingerprint(self.chart, ['--description', '-fast deploy']))


if __name__ == '__main__':
  unittest.main()
