# Tilt Extensions
This is the official Tilt Extension Repository. All extensions here have been vetted and approved by the Tilt Team.

## How to Contribute an Extension
So you want to contribute an extension!

We welcome additional extensions as pull requests.

We want everyone to feel at home in this repo and its environs; please see our [Code of Conduct](CODE_OF_CONDUCT.md) for some rules that govern everyone's participation.

## Extension Code Guidelines(?)
Each extension should live in its own directory in the root of this repo and have at least a Tiltfile, and optionally other files. For a very simple example see the [hello world extension](https://github.com/windmilleng/tilt-extensions/tree/master/hello_world). For a more complex example, see the [Tilt Extension Authoring guide](TODO).

Extension names much match these rules:
1. Name can only contain URL-friendly characters
2. Name length must be greater than zero
3. Name cannot start with a period (.)
4. Name cannot start with an underscore
5. Name cannot contain `:`
6. Name cannot contain leading or trailing spaces
7. Name cannot be any of these banned names:
- `tilt_modules`
- `tiltfile`
8. Name cannot contain more than 214 characters
