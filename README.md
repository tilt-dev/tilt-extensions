# Tilt Extensions
This is the official Tilt Extensions Repository. Read more in [docs](https://docs.tilt.dev/extensions.html).

All extensions have been vetted and approved by the Tilt team.

- [`api_server_logs`](/api_server_logs): Print API server logs. Example from [Contribute an Extension](https://docs.tilt.dev/contribute_extension.html).
- [`conftest`](/conftest): Use [Conftest](https://www.conftest.dev/) to test your configuration files.
- [`docker_build_sub`](/docker_build_sub): Specify extra Dockerfile directives in your Tiltfile beyond [`docker_build`](https://docs.tilt.dev/api.html#api.docker_build).
- [`hello_world`](/hello_world): Print "Hello world!". Used in [Extensions](https://docs.tilt.dev/extensions.html).
- [`jest_test_runner`](/jest_test_runner): Jest JavaScript test runner. Example from [Contribute an Extension](https://docs.tilt.dev/contribute_extension.html).
- [`min_tilt_version`](/min_tilt_version): Require a minimum Tilt version to run this Tiltfile.
- [`namespace`](/namespace): Functions for interacting with namespaces.
- [`pack`](/pack): Build container images using [pack](https://buildpacks.io/docs/install-pack/) and [buildpacks](https://buildpacks.io/).
- [`print_tiltfile_dir`](/print_tiltfile_dir): Print all files in the Tiltfile directory. If recursive is set to True, also prints files in all recursive subdirectories.
- [`procfile`](/procfile): Create Tilt resources from a foreman Procfile.
- [`restart_process`](/restart_process): Wrap a `docker_build` to restart the given entrypoint after a Live Update (replaces `restart_container()`)

## Contribute an Extension
See [Contribute an Extension](https://docs.tilt.dev/contribute_extension.html).

We want everyone to feel at home in this repo and its environs; please see our [Code of Conduct](CODE_OF_CONDUCT.md) for some rules that govern everyone's participation.
