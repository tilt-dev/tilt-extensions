# Logger

Author: [Nico Braun](https://github.com/gebinic)

Simple and customizable logger. The logger respects the typical hierarchy of log levels. A log level can be customized with the environment variable `LOGGER_LOG_LEVEL`, default: `info`. Each log function (`debug`, `info`, `warning` and `error`) automatically checks, if the corresponding log level is enabled. All of the functions below are published as `logger` struct.

Log level hierarchy:

```
debug -> "debug", "info", "warning" and "error"
info -> "info", "warning" and "error"
warning -> "warning" and "error"
error -> "error" only
```

Optionally, line separators (i.e. log separators) can be used *before* **and** *after* the log line. This behavior can be controlled either with function parameters or the environment variable `LOGGER_USE_LOG_SEPARATOR` (must be `True` or `False` (case insensitive), default: `False`). The log separator itself can be customized with the environment variable `LOGGER_LOG_SEPARATOR`, default: ``'\n' + '*' * 20 + '\n'``. Example with log separator (error logging):

```
Loading Tiltfile at: /path/to/Tiltfile
Traceback (most recent call last):
  /path/to/Tiltfile:12:6: in <toplevel>
Error in my_function: 
********************
My error log
********************
```

## Functions

### is_debug_enabled

```
is_debug_enabled(): bool
```

Whether debug logging is enabled.

### debug

```
debug(content: str, use_log_separator: bool): None
```

Prints debug log.

* `content (str)` - the content to be logged
* `use_log_separator` - whether a log separator should be printed *before* **and** *after* the log line. Default: `False`

### is_info_enabled

```
is_info_enabled(): bool
```

Whether info logging is enabled.

### info

```
info(content: str, use_log_separator: bool): None
```

Prints info log.

* `content (str)` - the content to be logged
* `use_log_separator` - whether a log separator should be printed *before* **and** *after* the log line. Default: `False`

### is_warning_enabled

```
is_warning_enabled(): bool
```

Whether warning logging is enabled.

### warning

```
warning(content: str, force_warn: bool, use_log_separator: bool): None
```

Prints warning log.

* `content (str)` - the content to be logged
* `force_warn (bool)` - whether the warning log should be printed with the built-in `warn(msg)` function, otherwise `print(msg)` is used. Default: `True`
* `use_log_separator` - whether a log separator should be printed *before* **and** *after* the log line. Default: `False`

### is_error_enabled

```
is_error_enabled(): bool
```

Whether error logging is enabled.

### error

```
error(content: str, force_fail: bool, use_log_separator: bool): None
```

Prints error log.

* `content (str)` - the content to be logged
* `force_fail (bool)` - whether the error log should be printed with the built-in `fail(msg)` function, otherwise `print(msg)` is used. Default: `True`
* `use_log_separator` - whether a log separator should be printed *before* **and** *after* the log line. Default: `True`

### log

```
log(log_level: str, content: str, force: bool, use_log_separator: bool): None
```

Prints a log.

* `log_level (str)` - the log level, valid values are: `debug`, `info`, `warning` and `error`. If the value is not valid, the `print(msg)` function is used to print the `content`
* `content (str)` - the content to be logged
* `force (bool)` - whether the log should be printed with the built-in `warn(msg)` or `fail(msg)` function, depends on the `log_level` parameter value, otherwise `print(msg)` is used. Default: `False`
* `use_log_separator` - whether a log separator should be printed *before* **and** *after* the log line. Default: `False`

## Usage

```
load('ext://logger', 'logger')

# automatically checks if debug log level is enabled
logger.debug('My debug log')

# automatically checks if info log level is enabled
logger.info('My info log')

# automatically checks if warning log level is enabled
logger.warning('My warning log')

# automatically checks if error log level is enabled
logger.error('My error log')

# consumes the "logger.info(...)" function under the hood
logger.log('info', 'My info log')

if logger.is_debug_enabled():
	# do stuff...

if logger.is_info_enabled():
	# do stuff...

if logger.is_warning_enabled():
	# do stuff...

if logger.is_error_enabled():
	# do stuff...
```
