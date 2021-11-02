# nix

Use build_nix_image (https://nix.dev/tutorials/building-and-running-docker-images) to build images for Tilt.

## Requirements

- `nix` (https://nixos.org/guides/install-nix.html)

## Functions

### `build_nix_image(ref: str, import_path: str = "", attr_path: str = "", deps: List[str] = [])`

- **ref**: The name of the image to build. Must match the image
name in the Kubernetes resources you're deploying.
- **path**: The path to your nix expression.
- **attr_path**: The attribute from the top-level nix expression containing the image you want to build.
- **deps**: A list of dependencies that can trigger rebuilds.

## Example Usage

```
load('ext://nix', 'build_nix_image')
build_nix_image("hello-world-image", "./nix/image.nix", "hello-world-image", "./nix/image.nix")
```

