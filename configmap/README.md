# Configmap

Author: [Nick Santos](https://github.com/nicks)

Helper functions for creating Kubernetes configmaps.

## Functions

### configmap_yaml

```
configmap_yaml(name: str, namespace: str = "", from_file: Union[str, List[str]] = None, watch: bool = True): Blob
```

Returns YAML for a config map generated from a file.

* `from_file` ( str ) – equivalent to `kubectl create configmap --from-file`
* `watch` ( bool ) - auto-reload if the files change

### configmap_create

```
configmap_create(name: str, namespace: str = "", from_file: Union[str, List[str]] = None, watch: bool = True)
```

Deploys a config map. Equivalent to

```
k8s_yaml(configmap_yaml('name', from_file=[...]))
```

## Example Usage

### For a Grafana config

```
load('ext://configmap', 'configmap_create')
configmap_create('grafana-config', from_file=['grafana.ini=./grafana.ini'])
```

## Caveats

- This extension doesn't do any validation to confirm that names or namespaces are valid.
