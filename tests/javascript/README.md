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
* **with_install (bool, optional)**: by default, False. If true, run `npm|yarn install` before running any tests, to ensure that your local dependencies are up to date.
* **project_root (str, optional)**: if `dir` is not the root of the JS project, specify the project root here so that Tilt can locate `package.json` and your lockfile. By default, will be set to `dir`. (Mostly relevant if you have specified `with_install=True`, so that Tilt can watch your `package.json` and lockfile and rerun in the install command either changes.)
* **extra_args (List[str], optional)**: any other args to pass to `npm|yarn test`.

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
