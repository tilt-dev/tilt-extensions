# NB: get_obj() is intended for attaching to existing
# deployments that were deployed using other tools or in the CI
# So we're preping an existing deployment
docker_build(
  'remote-dev-test-image',
  '.'
)
k8s_yaml('deployment.yaml')
