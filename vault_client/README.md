# Vault client

Author: [Ismael Fernandez](https://github.com/ismferd)

Contributors:

- [Diogo Kiss](https://github.com/diogokiss)

The purpose of this extension is to easily fetch secrets from a [Vault](https://www.vaultproject.io/) instance.

It allows you to reach Vault and read your secrets using a Vault token.

## Requirements

- [Vault CLI](https://developer.hashicorp.com/vault/install)

## Functions

### `vault_set_env_vars(vault_addr: str, vault_token: str)`

Set up the `VAULT_ADDR` and `VAULT_TOKEN` environment variables.

### `vault_read_secret(path: str, field: str) return str`

> [!IMPORTANT]
> This function is not recommended for use with Vault's KV secrets engine version 2.

Return the value of the secret field specified by the given `path` and `field`.
This function is a wrapper around the `vault read` command.

### `vault_kv_get(path, field, mount=None) return str`

> [!IMPORTANT]
> Prefer this function if you are using Vault's KV secrets engine.
> In particular, if you are using K/V version 2.

Return the value of the secret field specified by the given `field`, `path`, and `mount`.
This function is a wrapper around the `vault kv get` command.

## Example Usage

```python
load('ext://vault_client', 'vault_read_secret', 'vault_set_env_vars', 'vault_kv_get')
vault_set_env_vars('https://localhost:8200','mytoken')
my_foo = vault_read_secret('path/myfoo', 'secret')
my_bar = vault_kv_get('path/mybar', 'secret', mount='mymount')
```
