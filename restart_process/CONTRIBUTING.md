# Contributing

## Releasing

If you have push access to the `tiltdev` repository on DockerHub, you can release a new version of the binaries used by this extension like so:
1. run `release.sh` (builds `tilt-restart-wrapper` from source, builds and pushes a Docker image with the new binary and a fresh binary of `entr` also installed from source)
2. update the image tag in the [Tiltfile](/restart_process/Tiltfile) with the tag you just pushed (you'll find the image referenced in the Dockerfile contents of the child image--look for "FROM tiltdev/restart-helper")
