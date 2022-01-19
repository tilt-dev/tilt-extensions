# Deployment

Author: [Nick Sieger](https://github.com/nicksieger)

Convenience helpers for creating Kubernetes deployments and services.


## Functions

### deployment_create

```
deployment_create(name: str, image: str, command: Union[str, List[str]] = None, namespace: str ="", replicas: int = None, ports: Union[str, List[str]] = [])
```

* `name` (string): The deployment name
* `image` (string): The image name
* `command` (string or list\[string\]): The command to run, if different from the entrypoint in the image
* `namespace` (string): The namespace to create the deployment in, if different from the current namespace.
* `ports` (string or list\[string\]): The ports to expose as a ClusterIP service.

Create a Kubernetes deployment in the current cluster. If ports specified, create a Kubernetes service connected to the given port(s) in the deployment.

### deployment_yaml

```
deployment_yaml(name: str, image: str, command: Union[str, List[str]] = None, namespace: str = "", replicas: int = None, port: Union[str,int] = None): Blob
```

Return a blob of Kubernetes YAML for a simple deployment.

* `name` (string): The deployment name
* `image` (string): The image name
* `command` (string or list): The command to run, if different from the entrypoint in the image
* `namespace` (string): The namespace to create the deployment in, if different from the current namespace.
* `replicas` (int): The number of replicas to create if different than 1.
* `port` (string or int): The container port to declare

### service_yaml

Return a blob of Kubernetes YAML for a service.

```
service_yaml(name: str, svc_type: str ='ClusterIP', external_name: str = None, namespace: str = "", ports: Union[str, List[str]] = []): Blob
```
* `name` (string): The service name
* `svc_type` (string): The service type (default `ClusterIP`)
* `external_name` (string): The external name to use with `svc_type='ExternalName'`
* `namespace` (string): The namespace to create the service in, if different from the current namespace.
* `ports` (string or list\[string\]): The port pairs to use for the service


## Examples

### Deploy an image from Docker Hub

```python
load('ext://deployment', 'deployment_create')

# Create a redis deployment
deployment_create('redis', 'redis')
```

# Deploy a custom built image

```python
load('ext://deployment', 'deployment_create')

# Build a custom nginx container
docker_build('web', './assets', dockerfile_contents="""
FROM nginx:latest
COPY . /usr/share/nginx/html
""")

# Deploy the custom nginx container and expose it as a service on port 80
deployment_create('web', 'web', ports='80')
```

## Caveats

- This extension doesn't do any validation to confirm that names or namespaces are valid.
