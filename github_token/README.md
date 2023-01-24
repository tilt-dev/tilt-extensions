# GitHub Token

Author: [Nick Sieger](https://github.com/nicksieger)

Ensure that the environment variable `$GITHUB_TOKEN` is set to a valid personal access token. Uses the GitHub CLI, if installed, to retrieve the token if none is set prior to launching Tilt.

*Note*: Developer must already be logged in with `gh auth login` in order for token retrieval to be successful.

## Function: `github_token`

```
github_token(
  check_npm_packages: List[str]
)
```

If `$GITHUB_TOKEN` is not already set, retrieve a token with the GitHub CLI.

* `check_npm_packages`: if provided, checks that the developer has access to the given GHPR packages (scoped as `@org/package_name`). If packages cannot be accessed, prints a message telling the developer to re-auth with the `gh` command line and add scope `-s read:packages`.
