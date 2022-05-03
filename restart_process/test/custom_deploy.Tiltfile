load('../Tiltfile', 'docker_build_with_restart')
docker_build_with_restart('testimage', '.', dockerfile='Dockerfile.test', entrypoint='/start.sh', live_update=[sync('start.sh', '/start.sh')])
k8s_custom_deploy(
  'custom_deploy',
  deps=['deployment.yaml'],
  apply_cmd='sed -e"s|image: testimage|image: ${TILT_IMAGE_0}|" deployment.yaml | kubectl apply -f - -oyaml',
  delete_cmd='kubectl delete -f deployment.yaml',
  image_deps=['testimage'],
)

# trigger a live update and see if the process is restarted
local_resource('test_update', './trigger_custom_deploy_live_update.sh', resource_deps=['custom_deploy'])
