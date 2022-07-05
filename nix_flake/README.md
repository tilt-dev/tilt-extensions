# nix-flake

Use build_flake_image to build images for Tilt from one or more flakes. Heavily inspired by the existing nix plugin.

## Author
Grayson Head

## Requirements

- 'nix' (https://nixos.org/guides/install-nix.html) Flake support must be enabled if pre `22.05`

## Functions

### `build_flake_image(ref, path = "", output = "", resultfile = "result", deps = [])`

- **ref**: The name of the image to build, must match the image.
- **path**: The path of the flake (directory where the `flake.nix` is located). This can also be the path to a remote flake I.E.: `github:graysonhead/factorio-bot` or, `git+ssh://git@your-company-git.com/repo`
- **output**: The flake output to be built.
-- **deps**: A list of dependencies that can trigger rebuilds.

## Example usage

One advantage to using flakes for building Tilt containers is that you can compose containers from many different sources, such as a local repo, github, and internal Git servers such as Github or Gitlab. 

This plugin runs `nix build {path}#{output}` to construct the container, so any valid flake path can be used by the plugin. A somewhat complete list of those can be found here (https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples)

```
load('ext://nix-flake', 'build_flake_image')
build_flake_image("some-container", ".", "container")
build_flake_image("some-other-container", "git+ssh://git@github.example.com/org/some-other-project", "container")
build_flake_image("yet-another-container", "~/some_other_project", "container")
```
