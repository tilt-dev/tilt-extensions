import json
import subprocess
import unittest

class TestHoneycomb(unittest.TestCase):
  def test_events(self):
    events = json.loads(subprocess.check_output(["python3", "../events.py"]))
    self.assertEqual(2, len(events))
    self.assertEqual('(Tiltfile)', events[0]['data']['name'])
    self.assertEqual('ok', events[0]['data']['update_status'])
    self.assertEqual('event-test', events[1]['data']['name'])
    self.assertEqual('in_progress', events[1]['data']['update_status'])

if __name__ == '__main__':
    unittest.main()
