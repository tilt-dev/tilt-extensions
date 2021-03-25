# Golang Tests in Tilt

A wrapper for [Tilt's testing functionality](https://docs.tilt.dev/tests_in_tilt.html) for easier Go test setup. This extension runs the specified tests (with the specified options) via [`go test`](https://golang.org/pkg/cmd/go/internal/test/).

## Usage
Load the extension with:
```python
load('ext://tests/golang', 'test_go')
```

### Parameters
* **name (str)**: name of the created test resource.
* **package (str)**: the package to test. May be in any format legible to [`go test`](https://golang.org/pkg/cmd/go/internal/test/), i.e.: absolute path, path relative to cwd, or path relative to `$GOROOT/src`.
* **deps (Union[str, List[str]])**: a list of files or directories to be added as dependencies to this test. Tilt will watch those files and will run the test when they change. Only accepts real paths, not file globs.

You may also pass the following optional parameters:
* **timeout (str, optional)**: if a single test binary runs longer than the timeout duration, panic. Must be a [Go-parseable duration string](https://golang.org/pkg/time/#ParseDuration) (e.g. "45s", "2m").
* **tags (List[str], optional)**: tags to pass to the `go test` call.
* **mod (str, optional)**: value to pass to the `-mod` flag. [As per the docs](https://golang.org/ref/mod#build-commands), should be one of: `mod`, `readonly`, or `vendor`.
* **recursive (bool, optional)**: by default, False. If true, run tests recursively, i.e. on the specified package _and all of its children_. This is equivalent to adding `/...` to the end of your package name.
* **ignore (List[str], optional)**: set of file patterns that will be ignored. Ignored files will not trigger builds and will not be included in images. Follows the [dockerignore syntax](https://docs.docker.com/engine/reference/builder/#dockerignore-file). Paths will be evaluated _relative to the Tiltfile_.
* **extra_args (List[str], optional)**: any other args to pass to `go test`. 

### Examples
1. Test the current directory, recursively
    ```python
   test_go('my-go-tests', '.', '.', recursive=True)
    
   # OR:
   test_go('my-go-tests', './...', '.')
    ```

2. Run tests in verbose mode, with a timeout
    ```python
   test_go('test-foo', 'github.com/myhandle/myproj/foo', './foo',
            timeout='30s', extra_args=['-v'])
    ```

3. Use tags and [build constraints](https://golang.org/cmd/go/#hdr-Build_constraints) to skip long-running/irrelevant tests
    * at the top of any files to skip:
    ```
    //+build !skiplongtests
    ```
   * in your Tiltfile:
    ```python
    test_go('my-go-tests', './pkg', './pkg',
            tags=['skiplongtests'], recursive=True)
    ```

4. Test individual Go packages
    * In most cases, a single `test_go` call will suffice for an entire project, because Go's caching should make sure that only the relevant tests are run for every given file change. However, if your project has any caching issues (e.g. is affected by [this bug](https://github.com/golang/go/issues/26562)), _or_ if you just want more granular visibility into tests, you can call `test_go` once for each package in your project, like so:
    ```python
    EXCLUDE = ['cmd/', 'integration/']  # don't test packges in these dirs
    EXCLUDE_PREFIXES = [os.path.abspath(excl) for excl in EXCLUDE]
    TRIM = ['internal/', 'pkg/']  # trim these prefixes from resource names
    
    def all_go_package_dirs():
        pkgs_raw = str(local('go list -f "{{.Dir}}" ./...')).rstrip().split("\n")
        pkgs = []
        for pkg in pkgs_raw:
            cleaned = pkg.strip()
            if cleaned and not any([cleaned.startswith(excl) for excl in EXCLUDE_PREFIXES]):
                pkgs.append(cleaned)
    
        return pkgs
    
    def pretty_name(s):
        s = os.path.relpath(s).lstrip('/')
        for trim in TRIM:
            s = s.replace(trim, '', 1)
        return s
    
    for pkg in all_go_package_dirs():
        test_go(pretty_name(pkg), pkg, pkg)
    ```
