load('../Tiltfile', 'docker_build_with_restart')

k8s_yaml('distroless/deployment.yaml')
k8s_resource('distroless', resource_deps=['build'], port_forwards='8081:8081')

local_resource(
  'build',
  'mkdir -p .build && GOOS=linux GOARCH=amd64 go build -o .build/distroless ./distroless/main.go',
  deps=['./distroless/main.go'])

docker_build_with_restart(
  'distroless-image',
  './.build',
  dockerfile_contents="""
FROM gcr.io/distroless/base-debian10
WORKDIR /app
ADD distroless distroless
ENTRYPOINT /app/distroless
""",
  entrypoint='/app/distroless',
  live_update=[sync('./.build/distroless', '/app/distroless')])
