# Git Resource

Author: [Bob Jackman](https://github.com/kogi)

Deploy a dockerfile from a remote repository -- or specify the path to a local checkout for local development.

## Usage
#### Install a Remote Repository

```python
load('ext://git_resource', 'git_resource')
git_resource('myResourceName', 'git@github.com:tilt-dev/tilt-extensions.git')
```

##### Additional Parameters

```python
git_resource(resource_name, path_or_repo, dockerfile='Dockerfile', yaml='', namespace='default', resource_deps=[], build_callback=None) -> str # return yaml for k8s deployment
```

* `resource_name` ( str ) – the name to use for this resource
* `path_or_repo` ( str ) – either the URL to the remote git repo, or the path to your local checkout
* `dockerfile` ( str ) – the path to your dockerfile, relative to your git repository's root
* `yaml` ( str ) – the yaml to pass to k8s to deploy your new resource (this should specify an image name of `<resource_name>-image`). If omitted, a basic, default deployment will be generated.
* `namespace` ( str ) – the namespace to deploy the chart to. This only applies when `yaml` is omitted.
* `resource_deps` ( List [ str ] ) – a list of resources on which this resource depends
* `build_callback` ( callable() ) – a callback function used to perform a custom build of your docker image. See below for more details. 

#### Custom Docker Builds

By default, git_resource will build your docker image by calling `docker_build(image_name, context, dockerfile)`
If your situation requires more nuance/complexity than that, you can pass a `build_callback` function pointer when making your call to `git_resource()`
This callback should have the following signature:

```python
build_callback(resource_name, directory, dockerfile='Dockerfile', yaml='default', namespace='default')
```

Where:
* `resource_name` ( str ) – is the name of the resource being build (this is the same value passed as the first argument to `git_resource()`)
* `directory` ( str ) – this is the local checkout of the git repository which should be used as your build context (if this is a remote git resource, this location will be a temporary directory within your tilt workspace)
* `dockerfile` ( str ) – the path to your dockerfile, relative to `directory` (this is the same value passed when calling `git_resource()`)
* `yaml` ( str ) – if you passed `yaml` when you called `git_resource()` this will hold that value
* `namespace` ( str ) – if you passed `namespace` when you called `git_resource()` this will hold that value, otherwise, it will contain a generic, default deployment. Can be used to generate/customize your own yaml as needed

Your callback should return a `yaml` string/blob defining a deployment which will be passed to k8s

##### Example

```python
def my_microservice_builder(resource_name, directory, dockerfile, yaml, namespace) -> str:
    local('some local command')  # customize your build process
    docker_build(<your custom args here>)
    
    return myCustomDeploymentYaml


git_resource('myMicroservice', 'git@example.com/myRepo.git', dockerfile='Dockerfile.dev', build_callback=my_microservice_builder) 
```

#### Taking it Further
##### Switch dependencies in/out of local development mode
###### Tiltfile
```python
load('ext://git_resource', 'git_resource')

config.define_string('microservice1-path', args=False, usage='Set this to a local path in order to do local dev')
config.define_string('microservice2-path', args=False, usage='Set this to a local path in order to do local dev')
options = config.parse()

git_resources = {
    'microservice1': options.get('microservice1-path') if options.get('microservice1-path', '') != '' else 'git@example.com/myFirstMicroservice.git',
    'microservice2': options.get('microservice1-path') if options.get('microservice1-path', '') != '' else 'git@example.com/mySecondMicroservice.git',
}

for resource_name, resource_path in git_resources.items():
    git_resource(resource_name, resource_path)
```

###### Shell
```shell
tilt up #start the default configuration

tilt args -- --microservice1-path /path/to/local/checkout
#now you can make local edits with hot-reloading
#once you get it working, commit and push to your git repo
tilt args -- --microservice1-path '' #switch back to remote mode
