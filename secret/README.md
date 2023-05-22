# Secret

Author: [Nick Santos](https://github.com/nicks)

Helper functions for creating Kubernetes secrets.

## Functions

### secret_yaml_generic

```
secret_yaml_generic(
    name: str,
    namespace: str = "",
    from_file: str | list[str] = None,
    secret_type: str = None,
    from_env_file: str = None
) -> Blob
```

Returns YAML for a generic secret.

Equivalent to [`kubectl create secret generic -o=yaml --dry-run=client`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-secret-generic-em-)

* `name` ( str ) - Secret name.
* `namespace` ( str ) - Secret namespace.
* `from_file` ( str | list[str] ) – Populate secret from a file path or multiple file paths.
* `secret_type` ( str ) - The type of secret to create.
* `from_env_file` ( str ) – Specify the path to a file to read lines of `key=val` pairs to create a secret.

### secret_create_generic

```
secret_create_generic(
    name: str,
    namespace: str = "",
    from_file: str | list[str] = None,
    secret_type: str = None,
    from_env_file: str = None
) -> None
```

Deploys a secret to the cluster. Equivalent to:

```
load('ext://secret', 'secret_yaml_generic')
k8s_yaml(secret_yaml_generic(...))
```

Arguments are the same as [`secret_yaml_generic`](#secret_yaml_generic).

### secret_from_dict

```
secret_from_dict(
    name: str,
    namespace: str = "",
    inputs: dict[str, Any] = {}
) -> Blob
```

Returns YAML for a secret from a dictionary. Equivalent to [`kubectl create secret generic --from-literal=key=value`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-secret-generic-em-)

* `name` ( str ) - Secret name.
* `namespace` ( str ) - Secret namespace.
* `inputs` ( dict ) - A dictionary of keys and values to use. Nesting is not supported.

### secret_yaml_registry

```
secret_yaml_registry(
    name: str,
    namespace: str = "",
    flags_dict: dict = {}
) -> Blob
```

Returns YAML for a `docker-registry` type secret. Equivelent to [`kubectl create secret docker-registry`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-secret-docker-registry-em-).

* `name` ( str ) - Secret name.
* `namespace` ( str ) - Secret namespace.
* `flags_dict` ( dict ) - A dictionary of keys and values to be passed to the command as flags (`--key=value`).

### secret_yaml_tls

```
secret_yaml_tls(
    name: str,
    cert: str,
    key: str,
    namespace: str = ""
) -> Blob
```

Returns YAML for a TLS secret. Equivalent to [`kubectl create secret tls`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-secret-tls-em-).

* `name` ( str ) - Secret name.
* `cert` ( str ) - Path to PEM encoded public key certificate.
* `key` ( str ) - Path to private key associated with given certificate.
* `namespace` ( str ) - Secret namespace.

### secret_create_tls

```
secret_create_tls(
    name: str,
    cert: str,
    key: str,
    namespace: str = ""
) -> None
```

Deploys a TLS secret to the cluster. Equivalent to

```
load('ext://secret', 'secret_yaml_tls')
k8s_yaml(secret_yaml_tls(...))
```

Arguments are the same as [`secret_yaml_tls`](#secret_yaml_tls).

## Example Usage

### For a Postgres password:

```
load('ext://secret', 'secret_create_generic')
secret_create_generic('pgpass', from_file='.pgpass=./.pgpass')
```

### For Google Cloud Platform Key:

```
load('ext://secret', 'secret_create_generic')
secret_create_generic('gcp-key', from_file='key.json=./gcp-creds.json')
```

### From a dict:

```
load('ext://secret', 'secret_from_dict')
k8s_yaml(secret_from_dict("secrets", inputs = {
    'SOME_TOKEN' : os.getenv('SOME_TOKEN')
}))
```

### For a docker-registry secret
```
k8s_yaml(registry_secret("artifact-registry", flags_dict = {
    'docker-server': 'registry_hostname',
    'docker-username': '_json_key',
    'docker-email': 'test@test.com,
    'docker-password': read_file(service-account.json')
}))
```

### For a TLS cert:

Check out [`mkcert`](https://github.com/FiloSottile/mkcert) for generating HTTPS certs for localhost.

```
load('ext://secret', 'secret_create_tls')
cert_file='./.secrets/cert.pem'
key_file='./.secrets/key.pem'
secret_create_tls('subdomain-localhost', cert=cert_file, key=key_file)
```

## Caveats

- This extension doesn't do any validation to confirm that names or namespaces are valid.
