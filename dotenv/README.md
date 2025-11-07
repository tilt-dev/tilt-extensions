# dotenv

Author: [ln](https://github.com/tachiniererin)

dotenv reads `.env` or another specified file and loads the key value pairs into the environment.
Supports multi-line strings, but only wrapped with double-quotes (`"`).

## Usage

```python
load('ext://dotenv', 'dotenv')
dotenv()
# or
dotenv(fn='my-config.env')
```
