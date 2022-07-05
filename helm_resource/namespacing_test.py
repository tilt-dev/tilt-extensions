import unittest
from namespacing import add_default_namespace

class TestNamespacing(unittest.TestCase):
  def assert_defaulted(self, expected, original, ns):
    self.assertEqual(expected, add_default_namespace(original, ns))

  def test_add_when_omitted(self):
    self.assert_defaulted("""
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: my-namespace
  name: hello
""", """
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello
""", "my-namespace")

  def test_add_when_empty(self):
    self.assert_defaulted("""
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: my-namespace
  name: hello
""", """
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello
  namespace:
""", "my-namespace")

  def test_add_in_list(self):
    self.assert_defaulted("""
apiVersion: v1
kind: List
items:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      namespace: my-namespace
      name: cm1
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      namespace: my-namespace
      name: cm2
""", """
apiVersion: v1
kind: List
items:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: cm1
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: cm2
""", "my-namespace")

  def test_ignore_explicit(self):
    self.assert_defaulted("""
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello
  namespace: world
""", """
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello
  namespace: world
""", "my-namespace")


if __name__ == '__main__':
    unittest.main()
