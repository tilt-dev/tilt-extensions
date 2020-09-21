# Use Snyk to test your configuration files

Author: [Shai Mendel](https://github.com/shaimendel)

[Snyk](https://https://snyk.io/) is a product to help developers to continuously find and fix vulnerabilities in open source libraries, containers and Infrastructure as Code configurations.

## Usage

The `snyk` extension can be run like so:

```python
load('ext://snyk', 'snyk')

snyk('kubernetes.yaml')
k8s_yaml('kubernetes.yaml')
k8s_resource('example',
    port_forwards=8000,
    resource_deps=['snyk'],
)
```
The function takes a number of arguments.

* `path`: path to file to test
* `name`: a name for the resource, defaults to snyk. Useful if you want multiple invocations

## Requirements

* The `snyk` binary must be on your path
