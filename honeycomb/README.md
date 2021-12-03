# Honeycomb

Author: [Nick Santos](https://github.com/nicks)

Report dev environment health to [`honeycomb`](https://honeycomb.io).

## Requirements

- `python3`
- A Honeycomb account (a free plan is fine for the volume of data we'll be sending)

## Usage

When you include this extension, Tilt starts a sidecar that periodically scrapes
data from the Tilt API and reports it to Honeycomb.

Set the following environment variables:

- `HONEYCOMB_API_KEY` - The key for your personal/team Honeycomb account.
- `HONEYCOMB_DATASET` - The dataset to log your metrics to.

Then add this to your Tiltfile:

```python
include('ext://honeycomb', 'honeycomb_collector')
honeycomb_collector()
```

You can also set the environment variable in your Tiltfile:

```python
include('ext://honeycomb', 'honeycomb_collector')
os.environ['HONEYCOMB_API_KEY'] = str(read_file('/path/to/private/key'))
os.environ['HONEYCOMB_DATASET'] = 'tilt-analytics'
honeycomb_collector()
```

Or conditionally enable it if the environment variable is set:

```python
include('ext://honeycomb', 'honeycomb_collector')
if os.environ.get('HONEYCOMB_API_KEY', '') and os.environ.get('HONEYCOMB_DATASET', ''):
    honeycomb_collector()
```

## Events

Reload the honeycomb-collector resource from the UI or `tilt trigger` to
force it to send events immediately.

### uiresource

A heartbeat of the current update status and runtime status of each resource in
the UI.

```
{'tilt_version': '0.23.1', 'user': 'nicks', 'name': '(Tiltfile)', 'runtime_status': 'not_applicable', 'update_status': 'ok', 'kind': 'uiresource'}
```

The 'user' field is populated if the user is logged into Tilt Cloud.

### dockerimage

Reports when a build completes.

```
{'tilt_version': '0.23.1', 'user': 'nicks', 'image_name': 'tilt-site', 'duration_ms': 2008, 'kind': 'dockerimage'}
```

## Future Work

Additional events are welcome!

But we also work with many teams who write their own sidecars for the metrics
they care about. That's OK too!  We're equally happy if you fork this sidecar
and use it to create your own dev env health collector.


