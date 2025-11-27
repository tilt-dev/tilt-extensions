# Helper functions for defaulting yaml.

import re


# Add default namespace for a single resource.
def add_default_namespace_resource(r, namespace, indent=""):
  # Find the part of the yaml that has the metadata: and following indented lines.
  meta = re.search("^%smetadata:\r?\n(\\s+.*\r?\n)*" % indent, r, re.MULTILINE)
  if not meta:
    return r
  print(meta.group(0))
  metadata = meta.group(0)

  # Remove empty namespace blocks.
  metadata = re.sub("\r?\n\\s+namespace:\\s*\r?\n", "\n", metadata, flags=re.MULTILINE)

  has_namespace = re.search("\r?\n\\s+namespace: *\\S", metadata, re.MULTILINE)
  if not has_namespace:
    # Detect the indentation level of fields within metadata
    # by finding the first indented field after "metadata:"
    field_indent_match = re.search("^%smetadata:\r?\n(\\s+)" % indent, metadata, re.MULTILINE)
    if field_indent_match:
      field_indent = field_indent_match.group(1)
    else:
      # Default to 2 spaces if we can't detect the indentation
      field_indent = indent + "  "
    
    metadata = re.sub("^%smetadata:" % indent,
                      "%smetadata:\n%snamespace: %s" % (indent, field_indent, namespace),
                      metadata, count=1)
    return r[0:meta.start()] + metadata + r[meta.end():]

  return r

# Add default namespace for a v1.List by half-assedly
# splitting the List into items.
def add_default_namespace_resource_list(r, namespace):
  meta = re.search("^(\\s+)metadata:\\s*$", r, flags=re.MULTILINE)
  if not meta:
    return r

  indent = meta.group(1)
  items = re.split('^%smetadata:\\s*$' % indent, r, flags=re.MULTILINE)
  for i in range(len(items)):
    if i == 0:
      continue

    items[i] = add_default_namespace_resource(
      '%smetadata:%s' % (indent, items[i]), namespace, indent=indent)

  return ''.join(items)

# We have to do namespace defaulting ourselves :(
# See: https://github.com/tilt-dev/tilt-extensions/issues/374
def add_default_namespace(yaml, namespace):
  if not namespace:
    return yaml

  resources = re.split('^---$', yaml, flags=re.MULTILINE)

  for i in range(len(resources)):
    r = resources[i]

    # Check to see if this is a resource list.
    kind = re.search("^kind:\\s*(\\w+)\\s*$", r, flags=re.MULTILINE)
    if kind and (kind.group(1) == "List"):
      resources[i] = add_default_namespace_resource_list(r, namespace)
    else:
      resources[i] = add_default_namespace_resource(r, namespace)

  return '---'.join(resources)
