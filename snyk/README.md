# Use Snyk to test your configuration files

Author: [Shai Mendel](https://github.com/shaimendel)
* Additional contributor: [Jim Armstrong](https://github.com/jimcodified)

[Snyk](https://https://snyk.io/) is a product to help developers to continuously find and fix vulnerabilities in open source libraries, containers and Infrastructure as Code configurations.

## Usage

The `snyk` extension can be run like so:

```python
load('ext://snyk', 'snyk')

docker_build('myimage:v1','.')

snyk('myimage:v1', 'container', 'snyk-cnr', 'example', '--file=Dockerfile')
snyk('deployment.yaml', 'iac', 'snyk-iac')

k8s_yaml('kubernetes.yaml')
k8s_resource('example',
    port_forwards=8000,
    resource_deps=['snyk'],
)
```

The function takes a number of arguments:

* **path**: path to the file or container image name:tag to test
* **test_type**: one of 'oss', 'container', or 'iac' corresponding to the various Snyk CLI tests
* **name**: a name for the resource. useful for labeling when running multiple tests. Defaults to 'snyk'.
* **k8s_dep**: used for test_type=='container' and sets Tilt re-test dependency. Ignored by other test types.
* **extra_opts**: additional CLI options; appended to the snyk command. see `snyk --help` for CLI options.
  * container: this is where to insert the 'file==path/to/Dockerfile' option
  * ' --severity-threshold=[high|medium|low]' is another useful consideration

## Requirements

* The `snyk` binary must be on your path

## Other notes

The re-test is currently set to manual. The first tests will be run automatically when you `tilt up` but subsequent tests need to be started manually so you only run the Snyk tests  when you're ready.
