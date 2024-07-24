# File extension

Author: [FreehuntX](https://github.com/freehuntx)

Helper functions to read/write files.

## Usage

### Read a file as text

```python
load('ext://file', 'read_file')

text = read_file('/tmp/some_file')
print(text) # Prints the content of /tmp/some_file
```

### Write text to a file

```python
load('ext://file', 'write_file')

write_file('/tmp/some_file', 'This is some text') # Writes to /tmp/some_file
print(read_file('/tmp/some_file')) # Prints the content
```

## Functions
### read_file(path)
#### Parameters
* `path` (str) – The path of the file to read
#### Result
* (str) - The content of the file 
### write_file(path, content)
#### Parameters
* `path` (str) – The path of the file to read
* `content` (str) – The text to write to the file
#### Result
* (void)
