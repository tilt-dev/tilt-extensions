# Tilt Extensions

[![Build Status](https://circleci.com/gh/tilt-dev/tilt-extensions/tree/master.svg?style=shield)](https://circleci.com/gh/tilt-dev/tilt-extensions)

This is the official Tilt Extensions Repository. Read more in [docs](https://docs.tilt.dev/extensions.html).

All extensions have been vetted and approved by the Tilt team.

- [`api_server_logs`](/api_server_logs): Print API server logs. Example from [Contribute an Extension](https://docs.tilt.dev/contribute_extension.html).
- [`cancel`](/cancel): Adds a cancel button to the UI.
- [`cert_manager`](/cert_manager): Deploys cert-manager.
- [`color`](/color): Allows colorful log prints.
- [`configmap`](/configmap): Create configmaps from files and auto-deploy them.
- [`conftest`](/conftest): Use [Conftest](https://www.conftest.dev/) to test your configuration files.
- [`coreos_prometheus`](/coreos_prometheus): Deploys Prometheus to a monitoring namespace, managed by the CoreOS Prometheus Operator and CRDs
- [`current_namespace`](/current_namespace): Reads the default namespace from your kubectl config.
- [`custom_build_with_restart`](/restart_process): Wrap a `custom_build` to restart the given entrypoint after a Live Update
- [`deployment`](/deployment): Create K8s deployments, jobs, and services without manifest YAML files.
- [`docker_build_sub`](/docker_build_sub): Specify extra Dockerfile directives in your Tiltfile beyond [`docker_build`](https://docs.tilt.dev/api.html#api.docker_build).
- [`docker_build_with_restart`](/restart_process): Wrap a `docker_build` to restart the given entrypoint after a Live Update
- [`dotenv`](/dotenv): Load environment variables from `.env` or another file.
- [`earthly`](/earthly): Build container images using [earthly](https://earthly.dev)
- [`execute_in_pod`](/execute_in_pod): Execute a command on a pod container.
- [`file_sync_only`](/file_sync_only): No-build, no-push, file sync-only development. Useful when you want to live-reload a single config file into an existing public image, like nginx.
- [`get_obj`](/get_obj): Get object yaml and the container's registry and image from an existing k8s resource such as deployment or statefulset
- [`git_resource`](/git_resource): Deploy a dockerfile from a remote repository -- or specify the path to a local checkout for local development.
- [`hasura`](/hasura): Deploys [Hasura GraphQL Engine](https://hasura.io/) and monitors metadata/migrations changes locally.
- [`hello_world`](/hello_world): Print "Hello world!". Used in [Extensions](https://docs.tilt.dev/extensions.html).
- [`helm_remote`](/helm_remote): Install a remote Helm chart (in a way that gets properly uninstalled when running `tilt down`)
- [`helm_resource`](/helm_resource): Deploy with the Helm CLI. New Tilt users should prefer this approach over `helm_remote`.
- [`honeycomb`](/honeycomb): Report dev env performance to [Honeycomb](https://honeycomb.io).
- [`jest_test_runner`](/jest_test_runner): Jest JavaScript test runner. Example from [Contribute an Extension](https://docs.tilt.dev/contribute_extension.html).
- [`k8s_attach`](/k8s_attach): Attach to an existing Kubernetes resource that's already in your cluster. View their health and live-update them in-place.
- [`k8s_yaml_glob`](/k8s_yaml_glob): Load kubernetes manifests by glob patterns.
- [`kim`](/kim): Use [kim](https://github.com/rancher/kim) to build images for Tilt
- [`knative`](/knative): Use [knative serving](https://knative.dev/docs/serving/) to iterate on scale-to-zero servers.
- [`ko`](/ko): Use [Ko](https://github.com/google/ko) to build Go-based container images
- [`kubebuilder`](/kubebuilder): Enable live-update for developing [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) projects.
- [`kubectl_build`](/kubectl_build): Get faster build cycles and smaller disk usage by building docker images directly in the k8s cluster with [BuildKit CLI for kubectl](https://github.com/vmware-tanzu/buildkit-cli-for-kubectl).
- [`kubefwd`](/kubefwd): Use [Kubefwd](https://kubefwd.com/) to bulk-forward Kubernetes services.
- [`local_output`](/local_output): Run a `local` command and get the output as string
- [`min_k8s_version`](/min_k8s_version): Require a minimum Kubernetes version to run this Tiltfile.
- [`min_tilt_version`](/min_tilt_version): Require a minimum Tilt version to run this Tiltfile.
- [`namespace`](/namespace): Functions for interacting with namespaces.
- [`nix`](/nix): Use [nix](https://nixos.org/guides/install-nix.html) to build nix-based container images.
- [`nix_flake`](/nix_flake): Use [nix flake](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html) to build images for Tilt from one or more flakes.
- [`ngrok`](/ngrok): Expose public URLs for your services with [`ngrok`](https://ngrok.com/).
- [`pack`](/pack): Build container images using [pack](https://buildpacks.io/docs/install-pack/) and [buildpacks](https://buildpacks.io/).
- [`podman`](/podman): Build container images using [podman](https://podman.io)
- [`print_tiltfile_dir`](/print_tiltfile_dir): Print all files in the Tiltfile directory. If recursive is set to True, also prints files in all recursive subdirectories.
- [`procfile`](/procfile): Create Tilt resources from a foreman Procfile.
- [`pulumi`](/pulumi): Install Kubernetes resources with [Pulumi](https://www.pulumi.com/).
- [`pypiserver`](/pypiserver): Run [pypiserver](https://pypi.org/project/pypiserver/) local container.
- [`restart_process`](/restart_process): Wrap a `docker_build` or `custom_build` to restart the given entrypoint after a Live Update (replaces `restart_container()`)
- [`secret`](/secret): Functions for creating secrets.
- [`snyk`](/snyk): Use [Snyk](https://snyk.io) to test your containers, configuration files, and open source dependencies.
- [`syncback`](/syncback): Sync files/directories from your container back to your local FS.
- [`tarfetch`](/tarfetch): Fetch new and updated files from a container to your local FS.
- [`tests`](/tests): Some common configurations for running your tests in Tilt.
- [`tilt_inspector`](/tilt_inspector): Debugging server for exploring internal Tilt state.
- [`uibutton`](/uibutton): Customize your Tilt dashboard with [buttons to run a command](https://blog.tilt.dev/2021/06/21/uibutton.html).
- [`vault_client`](/vault_client): Reach secrets from a Vault instance.
- [`wait_for_it`](/wait_for_it): Wait until command output is equal to given output.
- [`base64`](/base64): Base64 encode or decode a string.
- [`yarn`](/yarn): Create Tilt resources from package.json scripts in a yarn workspace.

## Contribute an Extension

See [Contribute an Extension](https://docs.tilt.dev/contribute_extension.html).

We want everyone to feel at home in this repo and its environs; please see our [Code of Conduct](CODE_OF_CONDUCT.md) for some rules that govern everyone's participation.
