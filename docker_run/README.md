# Docker Run

Author: [Nick Sieger](https://github.com/nicksieger)

Run a single docker container, as one would with `docker run`.

The difference between this extension and a simple `docker run` command in a `local_resource` is that `docker_run` allows Tilt to manage the image build and inject the latest content-based tag. This is accomplished using Tilt's built-in `docker_compose` orchestration. `docker_run` builds compose YAML and hands it over to `docker_compose`.


## Functions

### docker_run

```
docker_run(
  image,
  command=None,
  container_name=None,
  env=None,
  env_file=None,
  entrypoint=None,
  expose=[], 
  links=[],
  networks=[],
  ports=[],
  privileged=False,
  restart=None,
  runtime=None,
  volumes=[],
  **kwargs
)
```

Run a single docker container, as one would with `docker run`.

Simulates `docker run` using Tilt's `docker_compose` orchestrator with inline
Compose YAML built by `docker_compose_yaml`.

- `image`: The image name to run
- `command`: An override for the command to run, either a string or list of strings.
- `container_name`: An override the container name
- `env`: Environment variables to set, a dict with string values.
- `env_file`: An environment file to use. Must be a path to a file or a list of paths.
- `entrypoint`: An override for the image entrypoint.
- `expose`: A list of ports to be exposed.
- `links`: A list of network links.
- `networks`: A list of networks to attach.
- `ports`: A list of ports to be forwarded, either a list of strings or port specs.
  See [the compose spec](https://github.com/compose-spec/compose-spec/blob/master/spec.md#ports) for details.
- `privileged`: Whether to run the container in privileged mode, a boolean.
- `restart`: Restart spec, one of `(no|always|on-failure|unless-stopped)`.
- `runtime`: The name of the runtime to use.
- `volumes`: A list of volumes to attach.
- `**kwargs`: Extra fields added to the compose spec.


### docker_compose_yaml

```
docker_compose_yaml(
  image,
  command=None,
  container_name=None,
  env=None,
  env_file=None,
  entrypoint=None,
  expose=[], 
  links=[],
  networks=[],
  ports=[],
  privileged=False,
  restart=None,
  runtime=None,
  volumes=[],
  **kwargs
): Blob
```

Build Compose YAML for a single service with the given image and parameters. The returned YAML will contain a `services` key with a single defined service.

- `image`: The image name to run
- `command`: An override for the command to run, either a string or list of strings.
- `container_name`: An override the container name
- `env`: Environment variables to set, a dict with string values.
- `env_file`: An environment file to use. Must be a path to a file or a list of paths.
- `entrypoint`: An override for the image entrypoint.
- `expose`: A list of ports to be exposed.
- `links`: A list of network links.
- `networks`: A list of networks to attach.
- `ports`: A list of ports to be forwarded, either a list of strings or port specs.
  See [the compose spec](https://github.com/compose-spec/compose-spec/blob/master/spec.md#ports) for details.
- `privileged`: Whether to run the container in privileged mode, a boolean.
- `restart`: Restart spec, one of `(no|always|on-failure|unless-stopped)`.
- `runtime`: The name of the runtime to use.
- `volumes`: A list of volumes to attach.
- `**kwargs`: Extra fields added to the compose spec.

## Examples

### Deploy an image from Docker Hub

```python
load('ext://docker_run, 'docker_run')

# Create a redis deployment with a readiness probe
docker_run('redis')
```

# Deploy a custom built image

```python
load('ext://docker_run, 'docker_run')

# Build a custom nginx image
docker_build('web', './assets', dockerfile_contents="""
FROM nginx:latest
COPY . /usr/share/nginx/html
""")

# Deploy the image and expose it as a service on port 80
docker_run('web', ports='80')
```

## Caveats

- This extension doesn't do any validation to confirm that any arguments are valid Docker or Docker Compose parameters.
