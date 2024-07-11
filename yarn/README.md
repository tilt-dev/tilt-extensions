# Yarn

Create Tilt resources from package.json scripts in a yarn workspace.

## Usage

### Create a Tilt resource for every package.json script in the specified workspace.

```python
load('ext://yarn', 'yarn')

yarn('path/to/package.json')
```

### Additional Usage

See [Configuration](#configuration-tilt_configjson) for parameter descriptions. Function parameters are merged with tilt_config.json values.

```python
load('ext://yarn', 'yarn')

yarn('path/to/package.json', auto_init=[], enabled_workspaces=[], enabled_scripts=[])
```

## Configuration: `tilt_config.json`

- `yarn_auto_init` ( List [ str ] ) – List of scripts to automatically run. The full resource name is expected like `<script>-<workspace>`.
- `yarn_enabled_workspaces` ( List [ str ] ) - List of workspaces to enable.
- `yarn_enabled_scripts` ( List [ str ] ) - List of scripts to enable for yarn. Common examples include `start`, `test`, `build`.
