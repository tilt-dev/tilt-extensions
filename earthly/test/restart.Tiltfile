# vim: set syntax=python:

load('../Tiltfile', 'earthly_build_with_restart')

earthly_build_with_restart(
    entrypoint='./main.sh',
    context='.',
    target='+hello',
    ref='helloimage',
    image_arg='IMAGE_NAME',
    ignore='./test.sh',
    extra_flags=[
        '--strict',
        # Needed when running tests in a docker container
        # https://github.com/earthly/earthly/issues/3736
        '--disable-remote-registry-proxy'
    ],
    extra_args=['--PORT=8000'],
    live_update=[run("echo 'updating!'")])

k8s_yaml('deployment.yaml')

k8s_resource(
    'example-earthly',
    port_forwards='8000',
    labels=['web']
)
