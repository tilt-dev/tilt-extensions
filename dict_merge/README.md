# Dictionary merge

Author: [Nico Braun](https://github.com/gebinic)

Merge two dictionaries recursively.

## Functions

### dict_merge

```
dict_merge(dct: dict, merge_dct: dict): None
```

Merges two dictionaries recursively. The values in `merge_dct` are kept in the `dct` if the function is successful.

* `dct (dict)` - the "base" dictionary
* `merge_dct (dict)` - the dictionary which should merged into `dct` 

## Usage

```
load('ext://dict_merge', 'dict_merge')
base_dct = {'key1': 'value1'}
merge_dct = {'key2': 'value2'}
dict_merge(base_dct, merge_dct)
print(base_dct) # output = {"key1": "value1", "key2": "value2"}
```
