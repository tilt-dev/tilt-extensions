#!/usr/bin/env bash

function rsync_complain() {
  echo $1
  echo "Install/update with your favorite package manager or download from:"
  echo -e "\thttps://github.com/WayneD/rsync/releases"
  exit 1
}

function verify_rsync_version_at_least() {
  which rsync  > /dev/null 2>&1
  exit_code="$?"
  if [[ "$exit_code" != "0" ]]; then
    rsync_complain "No local rsync executable found (need version >= $1)"
  fi

  regex='^.*version ([0-9]+\.[0-9]+\.[0-9]+).*$'
  if [[ $(rsync --version) =~ $regex ]]; then
    version=${BASH_REMATCH[1]}
    if [[ $version < $1 ]]; then
      rsync_complain "Need local rsync version >= $1 (got $version)"
    fi
  else
    rsync_complain "Could not parse local rsync version (need version >= $1)"
  fi
}

verify_rsync_version_at_least $1
