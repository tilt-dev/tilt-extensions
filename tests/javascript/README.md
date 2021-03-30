# Javascript Tests in Tilt

A wrapper for [Tilt's testing functionality](https://docs.tilt.dev/tests_in_tilt.html) for easier Go test setup. Currently, we offer extensions for running the specified tests with [Jest](https://jestjs.io/) via your JS package manager (currently either [npm](https://www.npmjs.com/) or [Yarn](https://yarnpkg.com/)).

## Usage
Load the function you need with:
```python
load('ext://tests/javascript', 'test_jest_npm')
```

### Parameters
Both `test_jest_npm` and `test_jest_yarn` accept the same parameters. These are:
* **name (str)**: name of the created test resource.
* **dir (str)**: directory from which to run `npm|yarn test`

You may also pass the following optional parameters:
* **deps (Union[str, List[str]])**: a list of files or directories to be added as dependencies to this test. Tilt will watch those files and will run the test when they change. By default, will be set to `dir`. Only accepts real paths, not file globs.
* **run_all (bool, optional)**: by default, False. If true, Jest will run all tests at the specified dir/path(s); otherwise, just tests affected by files changed since last commit.
* **with_install (bool, optional)**: by default, False. If true, run `npm|yarn install` before running any tests, to ensure that your local dependencies are up to date.
* **project_root (str, optional)**: if `dir` is not the root of the JS project, specify the project root here so that Tilt can locate `package.json` and your lockfile. By default, will be set to `dir`. (Mostly relevant if you have specified `with_install=True`, so that Tilt can watch your `package.json` and lockfile and rerun in the install command either changes.)
* **ignore (List[str], optional)**: set of file patterns that will be ignored. Ignored files will not trigger builds and will not be included in images. Follows the [dockerignore syntax](https://docs.docker.com/engine/reference/builder/#dockerignore-file). Paths will be evaluated _relative to the Tiltfile_.
* **extra_args (List[str], optional)**: any other args to pass to `npm|yarn test`.
* **\*\*kwargs**: will be passed to the underlying `test` call

### Examples
1. Run tests in a directory
    ```python
   test_jest_yarn('test-js', './web')
    ```

2. Run tests in a directory other than the project root
    ```python
   # 'package.json' and 'yarn.lock' both live in './web/'
   test_jest_yarn('test-js', './web/src',
                  with_install=True, project_root='./web')
    ```

3. Run tests with notifications
    ```python
   test_jest_yarn('test-js', './web',
                  extra_args=['--notify'])
    ```

4. Run your slow/expensive tests manually
    ```python
    test_jest_yarn('integration-tests', './integration',
                trigger_mode=TRIGGER_MODE_MANUAL, auto_init=False)
    ```
   The `trigger_mode` and `auto_init` parameters will be passed to the underlying `test` call (see docs on [Manual Update Control](https://docs.tilt.dev/manual_update_control.html)).

4. Run only tests related to file changed since the last commit--except in CI mode, which should run _all_ tests
    ```python
    test_jest_yarn('test-js', './web',
                      run_all=config.tilt_subcommand == 'ci')
    ```
