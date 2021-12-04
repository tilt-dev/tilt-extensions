#!/bin/bash

cd "$(dirname "$0")"

set -ex
tilt ci
syncback_dir=$(cat syncback-dir.txt)
test -f $syncback_dir/python/main.py
test -f $syncback_dir/ruby/main.rb
tilt down --delete-namespaces
rm -rf $syncback_dir syncback-dir.txt
