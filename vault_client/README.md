# Vault client

Author: [Ismael Fernandez](https://github.com/ismferd)

The purpose of this extension is to easily fetch secrets from a [Vault](https://www.vaultproject.io/) instance

You will be able to reach vault and get your secrets using a token

## Requirements

- `Vault cli`

## Functions

### `vault_set_env_vars(vault_addr: str, vault_token: str)`

Set up the `VAULT_ADDR`and the `VAULT_TOKEN` as envvars.

### `vault_read_secret(path: str, field: str) return str`

Return the value of your secret.

Under the hood, it is doing te command `vault read -field=$fiel $path"`

## Example Usage

```
load('ext://vault_cli', 'vault_read_secret', 'vault_set_env_vars')
vault_set_env_vars('https://localhost:8200','mytoken')
my_foo = vault_read_secret('path/myfoo', 'value')
my_bar = vault_read_secret('path/mybar', 'foobar')
```
