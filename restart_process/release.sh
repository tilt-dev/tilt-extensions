#!/bin/bash

set -e

TIMESTAMP=$(date +'%Y-%d-%m')
IMAGE_NAME='tiltdev/restart-scripts'
IMAGE_WITH_TAG=$IMAGE_NAME:$TIMESTAMP

# build Docker image with our start and restart scripts from latest master
docker build . -t $IMAGE_NAME
docker push $IMAGE_NAME

docker tag $IMAGE_NAME $IMAGE_WITH_TAG
docker push $IMAGE_WITH_TAG



