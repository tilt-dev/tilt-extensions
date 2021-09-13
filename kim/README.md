# kim

Author: [Lasse Højgaard](https://github.com/lhotrifork)

Use kim (https://github.com/rancher/kim) to build images for Tilt.

## Functions

### `kim_build(ref: str, import_path: str, deps: List[str] = [])`

- **ref**: The name of the image to build. Must match the image
   name in the Kubernetes resources you're deploying.
- **import_path**: A Go import path of the binary to build.
- **deps**: A list of dependencies that can trigger rebuilds.

## Example Usage

```
load('ext://kim', 'kim_build')
kim_build('hello-world-image', '.')
```

