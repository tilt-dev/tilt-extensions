# `nerdctl` Extension

Authors:

* [Milas Bowman](https://github.com/milas)

Use [nerdctl][] to build Tilt images for local clusters that use [containerd][] like Rancher Desktop.

Images are built directly into the container runtime avoiding the need to push to a local registry.

## Example Usage

```python
load('ext://nerdctl', 'nerdctl_build')

nerdctl_build(
    ref='registry.example.com/my-image',
    context='.',
)
```

## API

### `nerdctl_build()`

The API closely mirrors the [`docker_build`][docker_build] API.

Images will be built in the `k8s.io` namespace so that they will be immediately usable by the cluster.

```python
def nerdctl_build(
    ref: str,
    context: str,
    build_args: Dict[str, str]={},
    dockerfile: str=None,
    dockerfile_contents: str=None,
    live_update: List[LiveUpdateStep]=[],
    match_in_env_vars: bool=False,
    ignore: Union[str, List[str]]=[],
    entrypoint: Union[str, List[str]]=[],
    target: str='',
    ssh: Union[str, List[str]]='',
    secret: Union[str, List[str]]='',
    extra_tag: Union[str, List[str]]='',
    cache_from: Union[str, List[str]]=[],
    platform: str='',
):
    pass
```

### Differences from `docker_build()`

Due to differences between containerd and Docker/moby as well as limitations in what Tilt allows for custom image builds, not all arguments or features can be supported.

#### Unsupported Arguments in `nerdctl_build()`

* `only`: Not supported by Tilt for custom builds
* `network`: Not supported by `nerdctl`
* `container_args`: Not supported by Tilt for custom builds
* `pull`: Not supported by `nerdctl`

#### Extra Arguments in `nerdctl_build()`

None

## Configuration

### `containerd` Address

If your `containerd` socket is located in a non-default location, you'll need to provide the address to Tilt.

Set the `CONTAINERD_ADDRESS` in your shell before launching Tilt:

```bash
CONTAINERD_ADDRESS="${XDG_RUNTIME_DIR}/containerd/containerd.sock" tilt up
```

Alternatively, set it in your `Tiltfile` with `os.putenv`:

```python
if 'CONTAINERD_ADDRESS' not in os.environ:
    os.putenv(
        'CONTAINERD_ADDRESS',
        os.path.join(
            os.getenv('XDG_RUNTIME_DIR'),
            'containerd',
            'containerd.sock'
        )
    )
```

## Troubleshooting

### `nerdctl: command not found` / `Custom build command failed: exit status 127`

Tilt cannot find `nerdctl` in your `PATH`.

Open `Rancher Desktop > Preferences > Supporting Utilities`, check the box for `nerdctl`, and retry your build in Tilt.

[nerdctl]: https://github.com/containerd/nerdctl
[containerd]: https://github.com/containerd/containerd
[docker_build]: https://docs.tilt.dev/api.html#api.docker_build
