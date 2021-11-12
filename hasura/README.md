# Hasura

This extension deploys [Hasura Graphql Engine](https://hasura.io/), runs the Hasura CLI console, and syncs metadata and migrations locally.

## Requirements

- Tilt and a valid cluster
- The [Hasura CLI](https://hasura.io/docs/latest/graphql/core/hasura-cli) installed locally
- `curl` installed locally

## Usage

Basic usage

```python
load('ext://hasura', 'hasura')

hasura()
```

This will deploy Hasura, expose it to port `8080`, start the console on port `9695`and expose PostgreSQL on port `5432`.
It will automatically create the required Hasura files and folder in the `path` directory it they don't already exist.
Any modification then done through the Hasura console will be stored locally.

## Use an alternative Helm Chart

The extension uses the [Hasura PlatyDev Helm Chart](https://artifacthub.io/packages/helm/platydev/hasura) to depoy Hasura. you can deploy Hasura in another way in using the `yaml` parameter e.g.:

```sh
hasura(yaml=helm('./my-local-hasura-chart'))
```

## `hasura` command Parameters

The full list of parameters accepted by `hasura` includes:

- `release_name`, defaults to `''`
- `path` defaults to `'.'`. It will synchronise `{path}/metadata` and `{path}/migrations` with the server through the Hasura CLI console.
- `resource_name` defaults to `'hasura'`
- `port` is the host port Hasura is redirected to, defaults to `8080`
- `postgres_port` defaults to `5432`
- `repository` of the Hasura image, defaults to `'hasura/graphql-engine'`
- `tag` of the Hasura image, defaults to `'latest'`
- `hasura_secret` defaults to `'hasura-dev-secret'`
- `postgresql_password` defaults to `'development-postgres-password'`. Be careful: this password is persisted in the Postgres PV, so a password change while the PV already exists won't have any effect. Let's wait for [this](https://github.com/helm/charts/issues/5167) or [that](https://github.com/bitnami/charts/issues/2061).
- `yaml` to define a Kubernetes resources to deploy Hasura instead of the default Helm Chart, defaults to `''`
- `console`, defaults to `True`. If set to false, it won't run the Hasura console locally, therefore won't apply migrations and metadata.

## Use the Hasura console as a side-car

You may want to start the console at a different time, or with another Hasura instance that may not be managed by Tilt or the current cluster.
It will try to connect to the given Hasura instance.

It will check if a project has been set locally in the path given as a parameter. If not, it will initiate it and load the existing metadata from the Hasura server.

### `hasura_console` command parameters

- `release_name`, defaults to `''`
- `path`, defaults to `'.'`, is the path of your local Hasura projet
- `hasura_resource_name`, defaults to `None`
- `hasura_secret`, defaults to ``'hasura-dev-secret'`
- `hasura_endpoint`, defaults to `'http://localhost:8080'`
- `wait_for_services`, is an array of http services that will be probed until resolved successfully before starting the console, in addition to the Hasura server in itseld. Defaults to `[]`

### Start the console at a different time

```python
load('ext://hasura', 'hasura')
load('ext://hasura', 'hasura_console')
hasura(console=False)
hasura_console(hasura_resource_name='hasura', wait_for_services=['http://another-service/healthz'])
```

### Start the console against an external Hasura instance

```python
load('ext://hasura', 'hasura_console')
hasura_console(hasura_endpoint='https://my-hasura.io', hasura_secret='my-hasura-admin-secret')
```
