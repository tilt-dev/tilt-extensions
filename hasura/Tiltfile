
# * Load extensions
load('ext://helm_remote', 'helm_remote')


def wait_for(url):
    return """while [[ "$(curl -s -o /dev/null -w ''%{{http_code}}'' {})" != "200" ]]; do sleep 5; done""".format(url)


def hasura(release_name='',
           path='.',
           resource_name='hasura',
           port=8080,
           postgres_port=5432,
           tag='latest',
           hasura_secret='hasura-dev-secret',
           postgresql_password='development-postgres-password',
           yaml=''
           ):
    # * Expose Hasura service
    hasura_resource = '{}-{}'.format(release_name,
                                     resource_name) if release_name else resource_name
    k8s_resource(hasura_resource,
                 port_forwards='8080:{}'.format(port),
                 links=[link('http://localhost:9695/', 'Hasura Console')])

    # * Expose Postgresql service
    postgresql_resource = '{}-postgresql'.format(
        release_name) if release_name else '{}-postgresql'.format(resource_name)
    k8s_resource(postgresql_resource,
                 port_forwards='5432:{}'.format(postgres_port))

    # * Deploy Hasura Helm Chart
    if yaml:
        k8s_yaml(yaml)
    else:
        helm_remote('hasura',
                    repo_url='https://charts.platy.dev',
                    release_name=release_name,
                    set=['imageConfig.tag={}'.format(tag),
                         'adminSecret={}'.format(hasura_secret),
                         'postgresql.postgresqlPassword={}'.format(
                        postgresql_password),
                    ]
                    )

    endpoint = 'http://localhost:{}'.format(port)
    #  ? fetch admin secret from k8s?
    #  "--admin-secret `kubectl get secret {} -o jsonpath='{{.data.adminSecret}}' | base64 -D`".format(hasura_resource),
    console_options = '--project {} --endpoint {} --admin-secret {}'.format(
        path,
        endpoint,
        hasura_secret
    )
    config = read_yaml(os.path.join(path, 'config.yaml'), False)
    if not config:
        local('mkdir -p {}'.format(os.path.join(path, '..')))
        local('hasura init {} --version 2 --endpoint {}'.format(path, endpoint))
        # * Bug in the latest hasura cli version - set metadata version.yaml to 3
        local('echo "version: 2" > {}'.format(
            os.path.join(path, 'metadata/version.yaml')))

    serve_cmds = [
        'hasura migrate apply {}'.format(console_options),
        'hasura metadata apply {}'.format(console_options),
        'hasura console {}'.format(console_options)
    ]

    # * Wait for Hasura, then run the console locally
    console_resource = '{}-hasura-console'.format(
        release_name) if release_name else 'hasura-console'
    local_resource(console_resource,
                   wait_for('{}/healthz'.format(endpoint)),
                   resource_deps=[hasura_resource],
                   serve_cmd=' && '.join(serve_cmds),
                   allow_parallel=True,
                   links=[link('http://localhost:9695/', 'Hasura Console')],
                   )
