#!/bin/bash

cd "$(dirname "$0")"

set -ex
tilt ci $@
syncback_dir=$(cat syncback-dir.txt)
test -f $syncback_dir/python/main.py
test ! -f $syncback_dir/python/example.txt
test -f $syncback_dir/ruby/main.rb
test ! -f $syncback_dir/ruby/example.txt
test -f $syncback_dir/rsync/rsync.txt
test ! -f $syncback_dir/rsync/example.txt
# Test that rsync was copied for containers that needed it
kubectl exec -n syncback-test -c python deploy/syncback-containers -- sh -c "[ -f /bin/rsync.tilt ]"
kubectl exec -n syncback-test -c ruby deploy/syncback-containers -- sh -c "[ -f /bin/rsync.tilt ]"
# Test that rsync was not copied because it was already installed
kubectl exec -n syncback-test -c rsync deploy/syncback-containers -- sh -c "[ ! -f /bin/rsync.tilt ]"
# Test that button was created with correct resource
test -f syncback-button.txt -a "$(cat syncback-button.txt)" = syncback-containers

tilt down --delete-namespaces
rm -rf $syncback_dir syncback-dir.txt syncback-button.txt
