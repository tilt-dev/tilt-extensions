# kim
Author: [Lasse Højgaard](https://github.com/lhotrifork)

Use [kim](https://github.com/rancher/kim) to build images directly within your Kubernetes cluster.

## Functions
### `kim_build(ref: str, context: str, ignore: List[str] = None, extra_flags: List[str] = None, **kwargs)`
- **`ref`**: The name of the image to build. Must match the image
   name in the Kubernetes resources you're deploying.
- **`context`**: The build context of the image to build. Expressed as a file path.
- **`ignore`**: Changes to the given files or directories do not trigger rebuilds. **Does not affect the build context.**
- **`extra_flags`**: Extra flags to pass to kim CLI expressed as argv style array.
- **`kwargs`**: extra options to pass to `custom_build` (e.g. `live_update` or `match_in_env_vars`)

## Example Usage
```
load('ext://kim', 'kim_build')
kim_build('hello-world-image', '.')
```

## Known Issues
* Image pull errors (e.g. `ErrImagePull`) might be seen briefly after build due to how kim asynchronously makes the image visible to K8s ([rancher/kim#84](https://github.com/rancher/kim/issues/84))
