# Use Snyk to test your configuration files

Author: [Shai Mendel](https://github.com/shaimendel)

[Snyk](https://https://snyk.io/) is a product to help developers to continuously find and fix vulnerabilities in open source libraries, containers and Infrastructure as Code configurations.

## Usage

The `snyk` extension can be run like so:

```python
load('ext://snyk', 'snyk')

snyk('iac-test', 'kubernetes.yaml', 'iac')
k8s_yaml('kubernetes.yaml')
k8s_resource('example',
    port_forwards=8000,
    resource_deps=['snyk'],
)
```
The function takes a number of arguments.
      name: a name for the resource. useful for labeling when running multiple tests.
      path: path to the file or container image name:tag to test
      test_type: one of 'oss', 'container', or 'iac' corresponding to the various Snyk CLI tests
      k8s_resource: used for container tests - sets the re-test dependency. ignored by other test types.
      *options: additional CLI options; appended to the snyk command. see `snyk --help` for usage.
          - container: this is where to insert the 'file==path/to/Dockerfile' option

## Requirements

* The `snyk` binary must be on your path


## Other notes
The re-test is currently set to manual. That way you only run the Snyk tests when you're ready.
