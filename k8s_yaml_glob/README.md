# Kubernetes YAML Glob

Author: [Glenn Franxman](https://github.com/gfranxman)

Load kubernetes manifests by glob patterns.

## Usage

First load the extension like:

    load('ext://k8s_yaml_glob', 'k8s_yaml_glob')
    
Then use it like this:

    # all of the .yaml files in the k8s directory.
    k8s_yaml_glob('./k8s/*.yaml')  
    
or like this:

    # all of the dev-*.yaml files in the k8s directory and subdirectories.
    k8s_yaml_glob('./k8s/**/dev-*.yaml')  
    
