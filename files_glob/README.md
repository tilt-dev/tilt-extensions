# files_glob

Author: Kim Eik

Expand glob-like patterns (e.g., `**/*.go`, `dir/*.templ`) into real file paths at Tiltfile load time for use in APIs that require concrete paths (like `deps=` in `docker_build`/`custom_build`).

It also ensures Tilt reloads when matching files are added by watching the base directories implied by the patterns.

## Functions

- files_glob(*patterns) -> [str]
  - Expands common glob-style patterns into a de-duplicated list of file paths.
  - Examples:
    - `dir/**/*.ext`  → recursively find files under `dir` matching `*.ext`
    - `dir/*.ext`     → non-recursive match within `dir`
    - `*.ext`         → match in current directory only
    - literal paths   → included as-is
- watch_glob(*patterns)
  - Adds `watch_file()` entries for base directories implied by patterns so Tilt reloads when new files appear. `files_glob()` calls this for you automatically.

Note: Implementation uses `bash`/`find` under the hood; it’s meant to be practical for common dev workflows, not a full glob engine.

## Usage

```python path=null start=null
# Optionally set your default extension repo first if not using the shared repo:
# v1alpha1.extension_repo(name='default', url='file:///path/to/tilt-extensions')

load('ext://files_glob', 'files_glob')

# Use with docker_build/custom_build deps
srcs = files_glob('**/*.go', 'web/*.templ', 'scripts/*.sh')

docker_build('myimg', '.', deps=srcs)
```

You can also import `watch_glob` explicitly if you want to add watches without expanding files:

```python path=null start=null
load('ext://files_glob', 'watch_glob')
watch_glob('**/*.sql', 'migrations/**/up/*.sql')
```


