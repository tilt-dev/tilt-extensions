# Ngrok

Author: [Nick Santos](https://github.com/nicks)

Create public URLs for your local services with [`ngrok`](https://ngrok.com/)

## Requirements

- `bash`
- `ngrok`
- GNU core utils (`tr`, `sort`) - `brew install coreutils`

## Usage

When you include this extension, Tilt starts an ngrok server on port 4040 with
no tunnels open by default.

Every service with a link or port-forward will have a new button labelled 'ngrok'.

Clicking the button will create a new tunnel. You can see all the currently
open tunnels at http://localhost:4040/.

## Examples

```python
v1alpha1.extension_repo(name='default', url='https://github.com/tilt-dev/tilt-extensions')
v1alpha1.extension(name='ngrok:config', repo_name='default', repo_path='ngrok')
```

## Future Work

### Authentication

Add a way to add password authentication too all ngrok tunnels.

### Allowlist/blocklist

Only create the ngrok option for certain services / disallow it from other services.

### Custom port

ngrok currently always starts on port 4040


