# kim

Author: [Lasse Højgaard](https://github.com/lhotrifork)

Use [kim](https://github.com/rancher/kim) to build images for Tilt.

## Limitations
As `kim build` will automatically push images onto kubernetes worker nodes this extension will not run `kim push`.

## Functions
### `kim_build(ref: str, context: str, ignore: List[str] = None, extra_flags: List[str]=None, **kwargs)`
- **ref**: The name of the image to build. Must match the image
   name in the Kubernetes resources you're deploying.
- **context**: The build context of the image to build. Expressed as a file path.
- **ignore**: Changes to the given files or directories do not trigger rebuilds.
      Does not affect the build context.
- **extra_flags**: Extra flags to pass to kim build expressed as argv style array.
- **kwargs**: will be passed to the underlying `custom_build` call

## Example Usage
```
load('ext://kim', 'kim_build')
kim_build('hello-world-image', '.')
```
