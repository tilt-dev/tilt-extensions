# wt0 (Worktree Zero)

Author: [Worktree Zero](https://github.com/lonormaly/worktree-zero)

Run one Tilt environment **per Git worktree** with zero collisions.

[Worktree Zero](https://github.com/lonormaly/worktree-zero) (`wt0`) creates
copy-on-write Git worktrees for parallel coding agents and gives every
runtime a stable identity: a slot, a machine-globally unique hundred-port
window, a runtime id, and a Docker Compose project name, exported as
`WT0_*` environment variables to the command it runs. This extension maps
those identities into Tilt, so N agents (or N humans) run N isolated dev
stacks from one Tiltfile — per-worktree namespaces, non-overlapping port
forwards, no per-project port arithmetic.

The extension only reads environment variables. Outside a Worktree Zero
runtime every helper degrades to slot 0 and the `wt0-local` identity, so
the same Tiltfile serves an ordinary checkout unchanged.

## Usage

```python
load('ext://wt0', 'wt0_port', 'wt0_namespace')
load('ext://namespace', 'namespace_create', 'namespace_inject')

ns = wt0_namespace()                       # e.g. wt0-1234567890ab
namespace_create(ns)
k8s_yaml(namespace_inject(read_file('k8s/app.yaml'), ns))
k8s_resource('web', port_forwards='%d:3000' % wt0_port(0))
k8s_resource('api', port_forwards='%d:8080' % wt0_port(1))
```

Start one environment per worktree:

```bash
wt0 run agent/checkout-fix -- tilt up --port "$WT0_PORT_BASE"
```

Or run a complete ephemeral test environment per worktree:

```bash
wt0 run agent/checkout-fix -- tilt ci
```

## Functions

| Function | Returns |
| --- | --- |
| `wt0_slot()` | The runtime's slot index; `0` outside a runtime. |
| `wt0_port(offset=0)` | A port inside the runtime's hundred-port window (`WT0_PORT_BASE + offset`, offset 0–99). Windows are machine-globally unique and bind-probed by `wt0`, so two worktrees — even from different repositories — never collide. |
| `wt0_runtime_id()` | The runtime UUID, or `wt0-local`. |
| `wt0_short_id()` | Last 12 characters of the runtime id — the UUIDv7 random tail, stable and label-safe. |
| `wt0_branch()` | The runtime's branch, or `''`. |
| `wt0_namespace(prefix='wt0')` | A per-runtime Kubernetes namespace name. |
| `wt0_compose_project()` | The runtime's Docker Compose project name. |
| `wt0_shared_namespace(prefix='wt0-shared')` | The stable namespace for a once-per-cluster shared-services tier. |
| `wt0_resource_name(base)` | A per-runtime tenant name inside a shared service, e.g. `appdb_1234567890ab`. |
| `wt0_slot_resource(base)` | A slot-keyed tenant name, e.g. `appdb_wt0_3` — bounded and reusable, for resources a setup hook resets. |

## Shared services, private app

Booting a full stack per worktree is maximal isolation. Most fleets prefer
shared services with a private app tier: databases and emulators deploy
once under `wt0_shared_namespace()`, and each worktree's dev server (with
native file watching and HMR) connects as a private tenant:

```python
load('ext://wt0', 'wt0_shared_namespace', 'wt0_resource_name', 'wt0_port')

k8s_yaml(namespace_inject(read_file('k8s/services.yaml'), wt0_shared_namespace()))

db_name = wt0_resource_name('appdb')       # e.g. appdb_1234567890ab
k8s_resource('web', port_forwards='%d:3000' % wt0_port(0))
```

Worktree Zero's checked-in lifecycle hooks make teardown reliable: a
`.wt0/hooks/pre-remove` script that runs `tilt down --delete-namespaces`
(and drops the tenant) is executed by every removal path, and a failing
hook vetoes the deletion instead of orphaning cluster state. See the
[dev environments guide](https://github.com/lonormaly/worktree-zero/blob/main/docs/dev-environments.md)
for the full pattern.
