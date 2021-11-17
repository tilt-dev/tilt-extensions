# Knative

Author: [Nick Santos](https://github.com/nicks)

Use [Knative Serving](https://knative.dev/docs/serving/) to iterate on services that scale to zero.

## Functions

### `knative_install()`

Installs the knative operators into your cluster.

Auto-configures knative to use any local dev registries.

### `knative_yaml(file_name)`

Registers a knative Serving resource for development.

Auto-configures the resource with min availability=1,
so that it will always be available for live updates.
Also adds a dependency on the resource created by `knative_install()`.

## Examples

See the [test directory](./test/Tiltfile) for a simple example.

## Implementation Notes

This extension configures knative for local development.
There are a few different pieces.

### Dependencies

Knative installs a lot of CRDs.

If you're creating a dev environment from scratch, you want to make sure all
those CRDs and their operators are healthy before you install resources.

This extension helps keep those deps straight.

### Developer Registries

Knative tries to resolve your image to a tag.

Tilt likes this behavior! In fact, Tilt likes it so much that it does this at
build-time (rather than at deploy-time).  When you're using Knative with Tilt,
this behavior is redundant.

The problem is that Knative's approach to resolving images does not work well
with dev registries. This extension tries to determine if you're using a dev
registry, and turns tag resolution off.

https://knative.dev/docs/serving/configuration/deployment/#skipping-tag-resolution

### Scale Bounds

If you're using `live_update`, and knative scales your service to zero, Tilt
won't have a place to sync your files.

We set the minimum number of pods to 1, to ensure there's
always a place to sync files.

https://knative.dev/docs/serving/autoscaling/scale-bounds/

Knative also provides a way to turn off scale-to-zero globally,
but this extension does it per-resource.

https://knative.dev/docs/serving/autoscaling/scale-to-zero/
