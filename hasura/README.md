# Hasura

This extension deploys [Hasura Graphql Engine](https://hasura.io/), runs the Hasura CLI console, and syncs metadata and migrations locally.

## Requirements

- Tilt and a valid cluster
- The [Hasura CLI](https://hasura.io/docs/latest/graphql/core/hasura-cli) installed locally
- `curl` installed locally

## Usage

Basic usage

```sh
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

## Parameters

The full list of parameters accepted by `hasura` includes:

- `release_name`, defaults to `''`
- `path` defaults to `'.'`. It will synchronise `{path}/metadata` and `{path}/migrations` with the server through the Hasura CLI console.
- `resource_name` defaults to `'hasura'`
- `port` is the host port Hasura is redirected to, defaults to `8080`
- `postgres_port` defaults to `5432`
- `tag` of the Hasura image, defaults to `'latest'`
- `hasura_secret` defaults to `'hasura-dev-secret'`
- `postgresql_password` defaults to `'development-postgres-password'`. Be careful: this password is persisted in the Postgres PV, so a password change while the PV already exists won't have any effect. Let's wait for [this](https://github.com/helm/charts/issues/5167) or [that](https://github.com/bitnami/charts/issues/2061).
- `yaml` to define a Kubernetes resources to deploy Hasura instead of the default Helm Chart, defaults to `''`
- `registry` from which images should be pulled, defaults to `quay.io/jetstack`
