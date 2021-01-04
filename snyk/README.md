# Use Snyk to test your configuration files

Author: [Shai Mendel](https://github.com/shaimendel)
* Additional contributors: 
	[Jim Armstrong](https://github.com/jimcodified)
	[Matt Jarvis](https://github.com/mattj-io)

[Snyk](https://https://snyk.io/) is a product to help developers to continuously find and fix vulnerabilities in open source libraries, containers and Infrastructure as Code configurations.

## Requirements

* The `snyk` binary must be on your path. See https://support.snyk.io/hc/en-us/articles/360003812538-Install-the-Snyk-CLI for details on installing, and register for a free Snyk account at https://app.snyk.io/login

## Usage

The extension takes a number of arguments:

name: a name for the resource. Useful for labeling when running multiple tests. Defaults to 'snyk'
target: path to the file/dir or container image name:tag to test
test_type: one of 'oss', 'container', or 'iac' corresponding to the various Snyk CLI tests
test_deps: automatically set for test types other than container, allows for setting an external file/dir dependency
extra_opts: additional CLI options; appended to the snyk command. see `snyk --help` for usage.
          - when using the container switch this is where to insert the '--file=path/to/Dockerfile' option
trigger: trigger mode - auto or manual, defaults to manual
mode: control Snyk exit code, info will always exit 0 - gate or info, defaults to gate

The `snyk` extension can be run in a variety of different ways:

```python
# Load the extension
load('ext://snyk', 'snyk')

# Scan Kubernetes YAML files - in this case manually triggered and in informational-only mode
snyk('kubernetes.yaml', 'iac', 'snyk-iac-manual', mode='info')

# Scan application code dependencies - in this case automatically on change and in gating mode
snyk('.', 'oss', 'snyk-oss-auto', mode='gate', trigger='auto')

# Manually scan Docker builds
# Set mutable tags for the initial build, Tilt will re-tag with immutable during deploy
custom_build('example-nodejs-image', 'docker build -t $EXPECTED_REF .', ['.'], tag='dev')
# Run snyk manually against the mutable tag, in informational mode, and also scan a Dockerfile in the same directory
snyk('example-nodejs-image:dev', 'container', 'snyk-cnr-manual', mode='info', extra_opts='--file=Dockerfile')

# Automatically scan Docker builds
# Extract the immutable tag on build and write to a file in the filesystem
custom_build('example-nodejs-image', 'docker build -t $EXPECTED_REF . && echo $EXPECTED_REF > /tmp/ref.txt', ['.'])
# Extract the tag from the file and strip any newlines
def get_tag():
    return str(read_file('/tmp/ref.txt')).rstrip('\n')    
# Run snyk automatically in informational mode when the file containing the tag changes
snyk(get_tag(), 'container', 'snyk-cnr-auto', test_deps='/tmp/ref.txt', mode='info', extra_opts='--file=Dockerfile', trigger='auto')

k8s_yaml('kubernetes.yaml')
k8s_resource('example-node.js',
    port_forwards=8000
)
```

