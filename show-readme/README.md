# Tilt Extension: Show README

## Overview

This Tilt extension adds a button to your Tilt resource that displays the contents of a specified markdown file (e.g., README.md) when clicked. It's a handy way to provide documentation, instructions, or any other information directly within the Tilt UI.

## Features

- Adds a button to Tilt resources.
- Displays the content of a markdown file in a user-friendly format.
- Customizable button text and icon.

## Prerequisites

To use this extension, you need to have the `mdv` pip package installed. `mdv` is a Markdown Viewer for the terminal.

### Installing `mdv`

You can install `mdv` using pip:

```sh
pip install mdv
```

## Example Tiltfile

```python
load('ext://show-readme', 'readme')

readme(
    name="my_readme_button",
    resource="my_resource",
    markdown_file_path="/path/to/README.md"
)
```

## Author
[Xinyu Kang](https://github.com/XinyuKang22)