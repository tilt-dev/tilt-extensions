# Cancel

Author: [Nick Santos](https://github.com/nicks)

The cancel extension adds a 'cancel' button for any resource
that adds a local_resource().

The cancel button immediately kills a running process by sending
a TERM signal.

## Requirements

- `bash`
- `jq`

## Usage

Add this line to your Tiltfile:

```python
include('ext://cancel')
```

That's it!

In the future, this will be a global extension that you don't need to include
in your Tiltfile.

## Implementation Notes

This doubles as an example of how to write a reactive controller
against the Tilt APIServer. This controller is written in bash.

### Future Work

- Support for cancelling other built-in types, like Kubernetes deploys and
Docker builds.

- Integration tests.

- Icons

- Escalating signals (if you hit cancel twice, it should send a KILL instead of
  a TERM).
  
- Windows Support (this currently only works on Unix)



