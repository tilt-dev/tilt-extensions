#!/bin/sh

EXPECTED_REF=${1}
BUILDER=${2}
BUILD_PATH=${3}

pattern='^(.*):.*$'

[[ ${EXPECTED_REF} =~ $pattern ]] # $pat must be unquoted
CACHING_REF="${BASH_REMATCH[1]}:tilt-build-pack-caching"

pack build ${CACHING_REF} -p ${BUILD_PATH} --builder ${BUILDER}
docker tag ${CACHING_REF} ${EXPECTED_REF}

echo "Successfully retagged image ${CACHING_REF} to ${EXPECTED_REF}"