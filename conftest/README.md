# Use Conftest to test your configuration files

Author: [Gareth Rushgrove](https://github.com/garethr)

[Conftest](https://conftest.dev) is a utility to help you write tests against structured configuration data, including  write tests for your Kubernetes configurations. This Tilt eextension makes it easy to run Conftest as part of your development environment.

## Usage

The `conftest` extension can be run like so:

```python
load('ext://conftest', 'conftest')

conftest('kubernetes.yaml')
k8s_yaml('kubernetes.yaml')
k8s_resource('example',
    port_forwards=8000,
    resource_deps=['conftest'],
)
```

Note that you'll need a `policy` directory with your Rego code. See the [Conftest](https://www.conftest.dev/)
documentation for basic setup and usage instructions.

The function takes a number of arguments, which map to the `conftest` CLI arguments.

* `path`: path to file to test
* `name`: a name for the resource, defaults to conftest. Useful if you want multiple invocations
* `all_namespaces`: use rules from all namespaces
* `combine`: combine all files passed in into one structure
* `data`: a list of paths to load additional data from
* `fail_on_warn`: fail even if only warnings are found
* `input`: input type if different from that autodetected from the file extension
* `namespace`: the namespace to use for rules, defauls to main
* `output`: the output format, can be stdout, json, tap or table
* `trace`: whether or not to show the full policy trace, useful for debugging
* `update`: download policies based on local configuration or from exlicit repositories
* `policy`: where to find the policy files, defaults to a directory called policy`

You can also pass any other arguments supported by [`local_resource`](https://docs.tilt.dev/api.html#api.local_resource).


## Requirements

* The `conftest` binary must be on your path
