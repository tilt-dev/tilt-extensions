# Pypiserver

This extension runs docker container with [pypiserver](https://pypi.org/project/pypiserver/). 

Author: [Jakub Stepien](https://github.com/korbajan)

## Requirements
- bash
- python
- docker (with compose)

## Usage

```
load(
    'ext://pypiserver',
    'run_pypiserver_container',
    'build_package',
)

pypiserver = run_pypiserver_container()
build_package('./test/foo')
```

This will:
- run pypiserver (with disabled authentication) docker container,
- build package from ***./test/foo*** and upload it to this pypiserver. 
 
Then if your Dockerfile contains ARG PIP_INDEX_URL you can use it with docker_build:

```
docker_build(
  ref='python_services_which_depends_on_foo_package',
  context=path_to_service_context_dir,
  dockerfile=path_to_service_dockerfile,
  build_args={'PIP_INDEX_URL': pypiserver}
)
```

or, depend on your needs, you can also export it directly to the environment tilt is runing under:

```
os.putenv('PIP_INDEX_URL', pypiserv)
```

## Functions

### `run_pypiserver()`
starts 'tilt-pypiserver' container with exposed port (by default 8222 if it is not already opened) and returns string with its address in form of ***http//localhost:{port}***

### `build_package(package_dir_path, name=None, upload=True, labels=[])`
builds a package from ***package_dir_path*** path - there has to be ***setup.py*** under this directory - and if upload is True then upload it to local pypiserver.

## Future work

Add support for authentication (mount user or default apache httpasswd file into pypiserver container)
Add custom build cmd for building package
Implement building based on pyproject.toml
