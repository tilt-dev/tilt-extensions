# Git Resource

Author: [Bob Jackman](https://github.com/kogi)

Deploy a dockerfile from a remote repository -- or specify the path to a local checkout for local development.

## Usage

### Install a Remote OR Local Repository

```python
load('ext://git_resource', 'git_resource')
git_resource('myResourceName', 'git@github.com:tilt-dev/tilt-extensions.git#master')
# -- OR --
git_resource('myResourceName', '/path/to/local/checkout')
```

This will clone/pull your repo, build your dockerfile, and deploy your image into the cluster all in one fell swoop.
This function is syntactic sugar and would be identical to sequentially making calls to `git_checkout()` and `deploy_from_dir()`

##### Parameters

```python
git_resource(resource_name, path_or_repo, dockerfile='Dockerfile', namespace='default', resource_deps=[], port_forwards=[], build_callback=None, deployment_callback=None) -> str # return yaml for k8s deployment
```

* `resource_name` ( str ) – the name to use for this resource
* `path_or_repo` ( str ) – either the URL to the remote git repo, or the path to your local checkout.  
If passing a repo url, a branch may be specified with a hash delimiter (i.e. `git@example.com/path/to/repo.git#myBranchNameHere`).  
If no branch is specified, defaults to `master`
* `dockerfile` ( str ) – the path to your dockerfile, relative to your git repository's root
* `namespace` ( str ) – the namespace to deploy the built image to. This can be overridden within the `deployment_callback` function (see: [Custom Deployment YAML][2])
* `resource_deps` ( List [ str ] ) – a list of resources on which this resource depends
* `port_forwards` ( List [ str, int ] ) – Local ports to connect to the pod. See [tilt reference][3]
* `build_callback` ( callable() ) – a callback function used to perform a custom build of your docker image (see: [Custom Docker Builds][1])
* `deployment_callback` ( callable() ) – a callback function used to generate custom deployment yaml for the newly build image (see: [Custom Deployment YAML][2])



### Checkout a Git Repository

```python
git_checkout('git@github.com:tilt-dev/tilt-extensions.git#master', '/path/to/local/checkout')
```

If `checkout_dir` does not exist, it will be created, and the repo will be cloned here.
If this repo is already checked out at this location, it will be synced with `origin` and the local copy will be updated to `HEAD`

>**WARNING**: *Be very careful if pointing this function at an existing local development directory.
>If `checkout_dir` already exists, the contents of the dir may be overwritten which could cause loss of data if there are any uncommitted changes at this location.*

##### Parameters

```python
git_checkout(repository_url, checkout_dir='', unsafe_mode=False)
```

* `repository_url` ( str ) – the URL to the remote git repo
* `checkout_dir` ( str ) – the directory into which to clone the repo. If omitted, defaults to `git_remote_checkout_dir`  
If this dir does not exist, it will be created.
For more info about `git_remote_checkout_dir`, see [Changing the Cache Location](#change-the-cache-location)
* `unsafe_mode` ( bool ) – Defaults to `False`. If set to `True`, then ignore existing modifications within `checkout_dir`
  * By default (safe mode ON), `git_checkout()` may fail under the following circumstances:
    * `checkout_dir` already exists and is not a git repository
    * `checkout_dir` already exists as a git repository, but has uncommitted local changes



### Deploy From a Local Checkout

```python
deploy_from_dir('myResourceName', '/path/to/local/checkout')
```

##### Parameters

```python
deploy_from_dir(resource_name, directory, dockerfile='Dockerfile', namespace='default', resource_deps=[], port_forwards=[], build_callback=None, deployment_callback=None)
```

* `resource_name` ( str ) – the name to use for this resource
* `directory` ( str ) - the directory to use as the docker build context
* `dockerfile` ( str ) - the path, relative to `directory` to the Dockerfile to be built
* `namespace` ( str ) – the namespace to deploy the built image to. This can be overridden within the `deployment_callback` function (see: [Custom Deployment YAML][2]).
* `resource_deps` ( List [ str ] ) – a list of resources on which this resource depends
* `port_forwards` ( List [ str, int ] ) – Local ports to connect to the pod. See [tilt reference][3]
* `build_callback` ( callable() ) – a callback function used to perform a custom build of your docker image (see: [Custom Docker Builds][1])
* `deployment_callback` ( callable() ) – a callback function used to generate custom deployment yaml for the newly build image (see: [Custom Deployment YAML][2])



### Deploy From a Git Repository

```python
deploy_from_repository('myResourceName', '/path/to/local/checkout')
```

##### Parameters

```python
deploy_from_repository(resource_name, repository_url, dockerfile='Dockerfile', namespace='default', resource_deps=[], port_forwards=[], build_callback=None, deployment_callback=None)
```

* `resource_name` ( str ) – the name to use for this resource
* `repository_url` ( str ) - the URL to the remote git repo. A branch may be specified with a hash delimiter (i.e. `git@example.com/path/to/repo.git#myBranchNameHere`).  
If no branch is specified, defaults to `master`
* `dockerfile` ( str ) - the path, relative to `directory` to the Dockerfile to be built
* `namespace` ( str ) – the namespace to deploy the built image to. This can be overridden within the `deployment_callback` function (see: [Custom Deployment YAML][2])
* `resource_deps` ( List [ str ] ) – a list of resources on which this resource depends
* `port_forwards` ( List [ str, int ] ) – Local ports to connect to the pod. See [tilt reference][3]
* `build_callback` ( callable() ) – a callback function used to perform a custom build of your docker image (see: [Custom Docker Builds][1])
* `deployment_callback` ( callable() ) – a callback function used to generate custom deployment yaml for the newly build image (see: [Custom Deployment YAML][2])



### Custom Docker Builds

By default, `git_resource()`, `deploy_from_dir()`, and `deploy_from_repository()` will build your docker image by calling `docker_build(image_name, context, dockerfile)`
If your situation requires more nuance/complexity than that, you can pass a `build_callback` function pointer when making your call to `git_resource()`
This callback should have the following signature:

```python
build_callback(resource_name, context, dockerfile='Dockerfile') # returns resultant image name
```

Where:
* `resource_name` ( str ) – is the name of the resource being built (this is the same value passed when calling `git_resource()`)
* `context` ( str ) – this is the root location of the build context (if this is a remote git resource, this location will be a temporary directory within your tilt workspace)
* `dockerfile` ( str ) – the path to your dockerfile, relative to `directory` (this is the same value passed when calling `git_resource()`)

Your callback should return a string containing the name of the image that was built (this will subsequently be passed to the `deployment_callback()` if specified (see: [Custom Deployment YAML][2]))

##### Example

```python
def my_microservice_builder(resource_name, directory, dockerfile) -> str: # returns resultant image name
    local('some local command')  # customize your build process
    docker_build(<your custom args here>)
    
    return myCustomImageName


git_resource('myMicroservice', 'git@example.com/myRepo.git', dockerfile='Dockerfile.dev', build_callback=my_microservice_builder) 
```


### Custom Deployment YAML

By default, `git_resource()`, `deploy_from_dir()`, and `deploy_from_repository()` will deploy your docker image by generating a very basic and generic YAML definition.
If your situation requires more nuance/complexity than that, you can pass a `deployment_callback` function pointer when making your call to `git_resource()`
This callback should have the following signature:

```python
deployment_callback(resource_name, image_name, namespace) # returns deployment definition yaml
```

Where:
* `resource_name` ( str ) – is the name of the resource being built (this is the same value passed when calling `git_resource()`)
* `image_name` ( str ) – is the name of the image to use for this deployment (this is the same value returned by your custom `build_callback()` if specified (see: [Custom Docker Builds][1]))
* `namespace` ( str ) – the namespace this image should be deployed to (this is the same value passed when calling `git_resource()`)  
This can be overridden by the final yaml returned by this function

Your callback should return a string/blob containing the kubernetes yaml definition for your deployment

##### Example

```python
def my_microservice_deployment_generator(resource_name, image_name, namespace) -> str: # returns deployment definition yaml
    return blob(f"""apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: {resource_name}
          namespace: {namespace}
          labels:
            app: {resource_name}
        spec:
          selector:
            matchLabels:
              app: {resource_name}
          template:
            metadata:
              labels:
                app: {resource_name}
            spec:
              containers:
              - name: {resource_name}
                image: {image_name}
                ports:
                - containerPort: 8080
                  name: http
    """)


git_resource('myMicroservice', 'git@example.com/myRepo.git', dockerfile='Dockerfile.dev', deployment_callback=my_microservice_deployment_generator)
```



### Change the Cache Location

By default, when calling `deploy_from_repository()`, or using `git_resource()` with a repository url, the repo will be cloned into the `.git-sources` directory at your workspace's root.
This location can be customized by calling `git_resource_set_checkout_dir(newDirectory)`.
Whether customizing this value or just using the default location, be sure this directory is added to your project's
`.tiltignore` file in order to prevent recursive re-processing of the main Tiltfile when the helm cache changes/updates.
See github [issue #3404](https://github.com/tilt-dev/tilt/issues/3404)



### Taking it Further
#### Switching dependencies in/out of local development mode
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
```


[1]: #custom-docker-builds
[2]: #custom-deployment-yaml
[3]: https://docs.tilt.dev/api.html#api.k8s_resource
