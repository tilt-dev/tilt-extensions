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
      if (len(events) == 6 and
          events[0]['data']['update_status'] == 'ok' and
          events[2]['data']['update_status'] == 'in_progress'):
        break

      time.sleep(1)
      wait_count = wait_count + 1

    events = json.loads(subprocess.check_output(["python3", "../events.py"]))
    self.assertEqual(6, len(events))

    self.assertEqual(['uiresource', 'uiresource', 'uiresource', 'uiresource', 'dockerimage', 'cmdimage'],
                     [e['data']['kind'] for e in events])

    res_events = [e for e in events if e['data']['kind'] == 'uiresource']
    self.assertEqual(['(Tiltfile)', 'bobo', 'event-test', 'uncategorized'],
                     [e['data']['name'] for e in res_events])
    self.assertEqual(['ok', 'ok', 'in_progress', 'ok'],
                     [e['data']['update_status'] for e in res_events])

if __name__ == '__main__':
    unittest.main()
