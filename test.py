#!/usr/bin/python3

import argparse
import os
import os.path
import subprocess

parser = argparse.ArgumentParser(description='Run extension tests')
parser.add_argument('--changed', action=argparse.BooleanOptionalAction,
                    help='Only run changed tests')
parser.add_argument('--dry-run', action=argparse.BooleanOptionalAction,
                    help='Print the tests to run without running them.')

args = parser.parse_args()

SKIPPED_TESTS=set([
  # TODO(milas): the prometheus resources need more CPU than
  #   our CI KIND cluster can provide
  "coreos_prometheus/test/test.sh",

  # TODO(milas): we use kind w/ containerd in CI, but there's
  #   not an easy to get access to the containerd socket. You
  #   can still run this manually on a machine with Rancher
  #   Desktop in containerd mode.
  "nerdctl/test/test.sh",

  # TODO(nick): Currently it's a PITA to run podman in CI,
  # so we've turned this off. You can still run it manually
  # on a machine with podman installed.
  "podman/test/test.sh",

  # TODO(nicks): Knative has a race condition where the webhooks
  # aren't ready when the deployment installs.
  # To turn this on, we'd need to add some way to wait for the webhooks to be ready.
  "knative/test/test.sh",

  # TODO(nick): Get nix working inside circleci
  "nix/test/test.sh",
  "nix_flake/test/test.sh"
])

directory_whitelist = set([])
if args.changed:
  # Determine what files changed.
  master_sha = subprocess.check_output(["git", "rev-parse", "origin/master"]).decode('utf-8').strip()
  diff_sha = subprocess.check_output(["git", "merge-base", master_sha, "HEAD"]).decode('utf-8').strip()

  committed_changes = subprocess.check_output([
    "git", "diff-tree", "--no-commit-id", "--no-renames", "--name-only", "-r", diff_sha, "HEAD"
  ]).decode('utf-8').strip().splitlines()

  uncommitted_changes = [
    f.split(' ')[-1] for f in
    subprocess.check_output([
      "git", "status", "--porcelain", "--no-renames",
    ]).decode('utf-8').strip().splitlines()
  ]
  changes = committed_changes + uncommitted_changes
  for c in changes:
    d = c.split(os.path.sep)[0]
    directory_whitelist.add(d)

# `git ls-files` instead of `find` to ensure we skip stuff like .git and ./git_resource/test/.git-sources
files = subprocess.check_output(["git", "ls-files", "**/test.sh"]).decode('utf-8').splitlines()
for f in files:

  # don't re-execute itself
  if f == "test.sh":
    continue

  if f in SKIPPED_TESTS:
    print("skipping %s: in manual whitelist" % f)
    continue

  d = f.split(os.path.sep)[0]
  if args.changed and (d not in directory_whitelist):
    print("skipping %s: directory not changed" % f)
    continue

  if args.dry_run:
    print("dry run: %s" % f)
    continue

  print("running %s" % f)
  subprocess.check_call([f])
