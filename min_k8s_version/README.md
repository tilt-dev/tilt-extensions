# Minimum Kubernetes Version

Specify a minimum Kubenetes version to run this TiltFile

If the minimum version is not met, Tilt will stop executing using the `fail` api

## Usage


```py
load('ext://min_k8s_version', 'min_k8s_version')
min_k8s_version('1.18.3')
```
