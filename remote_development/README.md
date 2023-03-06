# Remote Development

Author: [Kobi Carmeli](https://github.com/kobik)

Develop, live update and debug against applications that were already deployed to Kubernetes from CI.

### `remote_development(obj: str, container_selector: str, namespace: str, port_forwards: port_forwards, disable_probes: bool, live_update: live_update, dockerfile: str, context: str)`
- **obj**: An object name in the form "kind/name", as you would express it to kubectl. e.g. deployment/my-deployment.
- **container_selector**: The container name in the pod that will be used for remote development.
- **namespace**?: The namespace of the object. If not specified, uses the current namespace.
- **dockerfile**?: The dockerfile that would be used for building a development image suitable for live-update.
Set up hot-reloading so the app can restart when the source files are changed and use a non-restricted user like 'nobody'.
- **context**?: Context to use for docker_build. Default: ".".
- **live_update**?: Live-update rules to copy files and run commands in the server whenever they change locally. Default: None.
- **port_forwards**?: Used to enable port-forwarding to the app running in the pod including exposing these ports in the pod if required. Default: None.
- **disable_probes**?: Disable liveness and readiness probes by removing them from the deployment, which is useful when debugging node applications. Default: False.


## Example Usage
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
load('ext://remote_development', 'remote_development')
remote_development(
  obj='deployment/example-nodejs',
  container_selector='my-container',
  dockerfile='Dockerfile.dev',
  disable_probes=True,
  live_update=[
    sync('./app', '/app'),
  ],
  port_forwards=[
    "8080:8080",
    "9229:9229"
  ]
)
```
