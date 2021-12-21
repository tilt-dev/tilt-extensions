import json
import subprocess
import unittest
import time

class TestHoneycomb(unittest.TestCase):
  def test_events(self):
    # Wait until the apiserver catches up.
    wait_count = 0
    while wait_count < 3:
      events = json.loads(subprocess.check_output(["python3", "../events.py"]))
      if (len(events) == 2 and
          events[0]['data']['update_status'] == 'ok' and
          events[1]['data']['update_status'] == 'in_progress'):
        break

      time.sleep(1)
      wait_count = wait_count + 1

    events = json.loads(subprocess.check_output(["python3", "../events.py"]))
    self.assertEqual(2, len(events))
    self.assertEqual('(Tiltfile)', events[0]['data']['name'])
    self.assertEqual('ok', events[0]['data']['update_status'])
    self.assertEqual('event-test', events[1]['data']['name'])
    self.assertEqual('in_progress', events[1]['data']['update_status'])

if __name__ == '__main__':
    unittest.main()
