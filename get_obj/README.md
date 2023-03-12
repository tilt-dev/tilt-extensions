# get obj

Author: [Kobi Carmeli](https://github.com/kobik)

Get object's yaml and image from an existing k8s resource such as deployment or statefulset.
Develop, live update and debug against applications that were already deployed to Kubernetes from CI/CD or other tools.

## `get_obj(name: str, kind: str, container_selector: str, namespace: str, disable_probes: bool)`
- **name**: The object's name as you would express it to kubectl. e.g my-deployment.
- **kind**: The object's kind. e.g 'deployment' or 'statefulset'
- **container_selector**: The container name in the pod that will be used for remote development.
- **namespace**?: The namespace of the object. If not specified, uses the current namespace.
- **disable_probes**?: Disable liveness and readiness probes by removing them from the deployment, which is useful when debugging node applications. Default: False.

### Example Usage
```
# Dockerfile.dev
FROM node:18-alpine
WORKDIR /app

COPY ./app ./
RUN npm ci

CMD [ \
  "npx", "nodemon", \
  "--verbose", \
  "--watch", ".", \
  "--ext", "js" , \
  "--signal", "SIGHUP", \
  "--inspect", \
  "index.js" \
]
```

```
# Tiltfile
load('ext://get_obj', 'get_obj')

# obj=struct(yaml, image, registry)
obj=get_obj(
  name='example-nodejs',
  kind='deployment',
  container_selector='my-container',
  disable_probes=True
)

docker_build(obj.registry, '.',
  live_update=[
    sync('./app', '/app'),
  ],
  ...
)

k8s_yaml(yaml)

k8s_resource(
  name,
  port_forwards=[
    "8080:8080",
    "9229:9229"
  ],
  ...
)
```
