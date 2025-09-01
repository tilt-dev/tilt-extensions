# Run Once

Author: [Vittorio Adamo](https://github.com/adamovittorio)

The Run Once extension provides a way to execute a function only once during a Tilt session. This extension is especially useful when working with multiple Tiltfiles that might declare the same resource. In such scenarios, without `run_once`, you would encounter errors due to resource redeclaration. For example, when multiple services require the same extension repository:

```python
load('ext://run_once', 'run_once')

# Without run_once - will cause errors if included in multiple Tiltfiles
v1alpha1.extension_repo(name='awesome-dev-platform', url='https://github.com/Organization/awesome-dev-platform', ref='v3.1.0')

# With run_once - safely registers the repo only once
for i in range(0, 5):
  run_once(
    name='awesome-dev-platform',
    fn=lambda: v1alpha1.extension_repo(name='awesome-dev-platform', url='https://github.com/Organization/awesome-dev-platform', ref='v3.1.0')
  )
```

This pattern ensures that common dependencies are only registered once during a Tilt session.

## Configuration

The extension uses a temporary directory to store state between Tilt updates. You can control where this directory is located by setting the `TILT_RUN_ONCE_TEMP_DIR` environment variable.

```sh
export TILT_RUN_ONCE_TEMP_DIR=/path/to/custom/dir
tilt up
```

You can control the verbosity of the extension by setting the `TILT_RUN_ONCE_QUIET` environment variable.

```sh
export TILT_RUN_ONCE_QUIET=False
tilt up
```

## How It Works

1. When Tilt starts, the extension creates a temporary directory
2. Resource names are recorded in a state file when they are first created
3. Subsequent calls with the same resource name will be skipped
4. The state is reset when Tilt is restarted

## Notes

- The state is maintained only during a single Tilt session
- When Tilt is restarted, all run_once functions will execute again
- Resources are tracked by name, so use unique names for different operations
