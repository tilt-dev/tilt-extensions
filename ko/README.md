# Ko

Author: [Nick Santos](https://github.com/nicks)

Use Ko (https://github.com/google/ko) to build images for Tilt.

## Functions

### `ko_build(ref: str, import_path: str, deps: List[str] = [], **kwargs)`

- **ref**: The name of the image to build. Must match the image
   name in the Kubernetes resources you're deploying.
- **import_path**: A Go import path of the binary to build.
- **deps**: A list of dependencies that can trigger rebuilds.
- **kwargs**: All remaining args will be passed to the underlying custom_build.

## Example Usage

A simple Go build:

```
load('ext://ko', 'ko_build')
ko_build('hello-world-image', 
         'github.com/tilt-dev/tilt-extensions/ko/test/cmd/hello-world')
```

You can use live_update, but you'll need to use a base image with `tar`
installed. (Ko defaults to an image without any Linux tools.)

```
load('ext://ko', 'ko_build')
ko_build('hello-world-image', 
         './cmd/hello-world',
         
         # You must have a ko.yaml with the contents:
         # defaultBaseImage: busybox
         live_update=[
           sync('./cmd/hello-world/kodata', '/var/run/ko'),
         ])
```
