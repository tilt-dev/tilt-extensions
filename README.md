# Tilt Extensions
This is the official Tilt Extension Repository. All extensions here have been vetted and approved by the Tilt Team.

## Finding an Extension
Here's a list of extensions along with a brief description. Try using your browsers search functionality to find an extension.

* **`api_server_logs`**: Print API server logs. Example from [Writing Tilt Extensions](https://docs.tilt.dev/writing_tilt_extensions.html).
* **`hello_world`**: A barebones example. Prints "Hello world!" when `hi()` is called.
* **`docker_build_sub`**: Like [`docker_build`](https://docs.tilt.dev/api.html#api.docker_build), but allows you to specify extra Dockerfile directives in your Tiltfile.
* **`procfile`**: Creates Tilt resources from a foreman Procfile.

## How to Contribute an Extension
We welcome additional extensions as pull requests.

We want everyone to feel at home in this repo and its environs; please see our [Code of Conduct](CODE_OF_CONDUCT.md) for some rules that govern everyone's participation.

Each extension should live in its own directory in the root of this repo and have at least a Tiltfile, and optionally other files. For a very simple example see the [hello world extension](https://github.com/windmilleng/tilt-extensions/tree/master/hello_world). For a more complex example, see [Writing Tilt Extensions](https://docs.tilt.dev/writing_tilt_extensions.html).

Be sure to add your extension to the extension index in README.md.
