# Current Namespace

The purpose of this extension is to easily fetch the active namespace within your kubernetes environment

You can use this to quickly setup remote deployments using Tilt without having to hardcode any namespace within your tiltfile

All you would have to do then would be to change your namespace using something like `kubens "your-namespace"` before running `tilt up`.
