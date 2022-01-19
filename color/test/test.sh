#!/bin/sh

set -e

cd "$(dirname "$0")"

echo "--- COLORS ENABLED ---"
expected="\x1b[0;32mHello\x1b[0m \x1b[0;34mWorld\x1b[0m!"
out=$(tilt ci)
echo "${out}"

if ! test "${out#*"$expected"}" != "${expected}"; then
    >&2 echo "Did not find expected output: '${expected}'"
    exit 1
else
    echo "PASS"
fi

echo "--- COLORS DISABLED ---"
expected="Hello World!"
out=$(NO_COLOR=1 tilt ci)
echo "${out}"

if ! test "${out#*"$expected"}" != "${expected}"; then
    >&2 echo "Did not find expected output: '${expected}'"
    exit 1
else
    echo "PASS"
fi
