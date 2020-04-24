#!/bin/bash

set -e

TIMESTAMP=$(date +'%Y-%m-%d')
IMAGE_NAME='tiltdev/entr'
IMAGE_WITH_TAG=$IMAGE_NAME:$TIMESTAMP

# build our binary
env GOOS=linux GOARCH=amd64 go build -o tilt-restart-wrapper main.go

# build Docker image with our statically compiled entr binary for Linux
docker build . -t $IMAGE_NAME
docker push $IMAGE_NAME

docker tag tiltdev/entr $IMAGE_WITH_TAG
docker push $IMAGE_WITH_TAG



