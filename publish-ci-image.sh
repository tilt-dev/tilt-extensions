#!/bin/bash

set -euo pipefail

IMAGE_NAME=docker/tilt-extensions-ci

docker buildx build --push --pull --platform linux/amd64 -t $IMAGE_NAME -f .circleci/Dockerfile .circleci

docker pull "$IMAGE_NAME"
DIGEST="$(docker inspect --format '{{.RepoDigests}}' "$IMAGE_NAME" | tr -d '[]')"

yq eval -i ".jobs.validate.docker[0].image = \"$DIGEST\"" .circleci/config.yml
yq eval -i ".jobs.test.docker[0].image = \"$DIGEST\"" .circleci/config.yml

