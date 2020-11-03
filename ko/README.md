# Ko

Author: [Nick Santos](https://github.com/nicks)

Use Ko (https://github.com/google/ko) to build images for Tilt.

## Functions

### `ko_build(ref: str, import_path: str, deps: List[str] = [])`

- **ref**: The name of the image to build. Must match the image
   name in the Kubernetes resources you're deploying.
- **import_path**: A Go import path of the binary to build.
- **deps**: A list of dependencies that can trigger rebuilds.

## Example Usage

```
load('ext://ko', 'ko_build')
ko_build('hello-world-image', 
         'github.com/mattmoor/warm-image/cmd/sleeper')
```

