# Tilt Extensions

[![Build Status](https://circleci.com/gh/tilt-dev/tilt-extensions/tree/master.svg?style=shield)](https://circleci.com/gh/tilt-dev/tilt-extensions)

This is the official Tilt Extensions Repository. Read more in [docs](https://docs.tilt.dev/extensions.html).

All extensions have been vetted and approved by the Tilt team.

- [`api_server_logs`](/api_server_logs): Print API server logs. Example from [Contribute an Extension](https://docs.tilt.dev/contribute_extension.html).
- [`cancel`](/cancel): Adds a cancel button to the UI.
- [`cert_manager`](/cert_manager): Deploys cert-manager.
- [`configmap`](/configmap): Create configmaps from files and auto-deploy them.
- [`conftest`](/conftest): Use [Conftest](https://www.conftest.dev/) to test your configuration files.
- [`coreos_prometheus`](/coreos_prometheus): Deploys Prometheus to a monitoring namespace, managed by the CoreOS Prometheus Operator and CRDs
- [`current_namespace`](/current_namespace): Reads the default namespace from your kubectl config.
- [`docker_build_sub`](/docker_build_sub): Specify extra Dockerfile directives in your Tiltfile beyond [`docker_build`](https://docs.tilt.dev/api.html#api.docker_build).
- [`dotenv`](/dotenv): Load environment variables from `.env` or another file.
- [`file_sync_only`](/file_sync_only): No-build, no-push, file sync-only development. Useful when you want to live-reload a single config file into an existing public image, like nginx.
- [`git_resource`](/git_resource): Deploy a dockerfile from a remote repository -- or specify the path to a local checkout for local development.
- [`hasura`](/hasura): Deploys [Hasura GraphQL Engine](https://hasura.io/) and monitors metadata/migrations changes locally.
- [`hello_world`](/hello_world): Print "Hello world!". Used in [Extensions](https://docs.tilt.dev/extensions.html).
- [`helm_remote`](/helm_remote): Install a remote Helm chart (in a way that gets properly uninstalled when running `tilt down`)
- [`jest_test_runner`](/jest_test_runner): Jest JavaScript test runner. Example from [Contribute an Extension](https://docs.tilt.dev/contribute_extension.html).
- [`kim`](/kim): Use [kim](https://github.com/rancher/kim) to build images for Tilt
- [`ko`](/ko): Use [Ko](https://github.com/google/ko) to build Go-based container images
- [`kubebuilder`](/kubebuilder): Enable live-update for developing [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) projects.
- [`kubectl_build`](/kubectl_build): Get faster build cycles and smaller disk usage by building docker images directly in the k8s cluster with [BuildKit CLI for kubectl](https://github.com/vmware-tanzu/buildkit-cli-for-kubectl).
- [`kubefwd`](/kubefwd): Use [Kubefwd](https://kubefwd.com/) to bulk-forward Kubernetes services.
- [`local_output`](/local_output): Run a `local` command and get the output as string
- [`min_k8s_version`](/min_k8s_version): Require a minimum Kubernetes version to run this Tiltfile.
- [`min_tilt_version`](/min_tilt_version): Require a minimum Tilt version to run this Tiltfile.
- [`namespace`](/namespace): Functions for interacting with namespaces.
- [`ngrok`](/ngrok): Expose public URLs for your services with [`ngrok`](https://ngrok.com/).
- [`pack`](/pack): Build container images using [pack](https://buildpacks.io/docs/install-pack/) and [buildpacks](https://buildpacks.io/).
- [`podman`](/podman): Build container images using [podman](https://podman.io)
- [`print_tiltfile_dir`](/print_tiltfile_dir): Print all files in the Tiltfile directory. If recursive is set to True, also prints files in all recursive subdirectories.
- [`procfile`](/procfile): Create Tilt resources from a foreman Procfile.
- [`restart_process`](/restart_process): Wrap a `docker_build` to restart the given entrypoint after a Live Update (replaces `restart_container()`)
- [`secret`](/secret): Functions for creating secrets.
- [`snyk`](/snyk): Use [Snyk](https://snyk.io) to test your containers, configuration files, and open source dependencies.
- [`syncback`](/syncback): Sync files/directories from your container back to your local FS.
- [`tarfetch`](/tarfetch): Fetch new and updated files from a container to your local FS.
- [`tests`](/tests): Some common configurations for running your tests in Tilt.
- [`tilt_inspector`](/tilt_inspector): Debugging server for exploring internal Tilt state.
- [`uibutton`](/uibutton): Customize your Tilt dashboard with [buttons to run a command](https://blog.tilt.dev/2021/06/21/uibutton.html).
- [`wait_for_it`](/wait_for_it): Wait until command output is equal to given output.
- [`nix`](/nix): Use [nix](https://nixos.org/guides/install-nix.html) to build nix-based container images.

## Contribute an Extension

See [Contribute an Extension](https://docs.tilt.dev/contribute_extension.html).

We want everyone to feel at home in this repo and its environs; please see our [Code of Conduct](CODE_OF_CONDUCT.md) for some rules that govern everyone's participation.
