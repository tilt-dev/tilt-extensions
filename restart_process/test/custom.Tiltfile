load('../Tiltfile', 'custom_build_with_restart')

k8s_yaml('failing-job.yaml')
custom_build_with_restart(
  'failing_job',
  command='docker build -t $EXPECTED_REF -f Dockerfile.failing .',
  deps=['fail.sh'],
  entrypoint='/fail.sh',
  live_update=[sync('./fail.sh', '/fail.sh')])


k8s_yaml('test-job.yaml')
custom_build_with_restart(
  'test_job',
  command='docker build -t $EXPECTED_REF -f Dockerfile.test .',
  deps=['start.sh'],
  entrypoint='/start.sh',
  live_update=[sync('./start.sh', '/start.sh')])
