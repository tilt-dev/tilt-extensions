# CoreOS Prometheus

This extension deploys CoreOS Prometheus to a monitoring namespace with some
modifications to the defaults to enable reading alerts defined via
'PrometheusRule' custom resource definitions.

Author: [Darragh Bailey](https://github.com/electrofelix)

## Usage

Basic usage
```
load(
    'ext://coreos_prometheus',
    'setup_monitoring',
    'get_prometheus_resources',
    'get_prometheus_dependencies',
)

setup_monitoring()

k8s_yaml(my_deployment)
k8s_resource(
    'my-resource',
    objects=get_prometheus_resources(my_deployment, 'my-resource')
    resource_deps=get_prometheus_dependencies(),
)
```

This will ensure your service along with any components of your service that
depend on prometheus are deployed after the prometheus CRDs have been created.

For example if you have yaml defining 'PrometheusRule' and 'ServiceMonitor'
components these will be grouped with your 'my-resource' and applied after the
'prometheus-crds' resources are ready.
