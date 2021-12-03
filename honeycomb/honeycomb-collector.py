import http.client as http_client
import json
import os
import subprocess
import time
import datetime as datetime

api_key = os.environ.get('HONEYCOMB_API_KEY', '')
dataset = os.environ.get('HONEYCOMB_DATASET', '')

if not api_key:
  print('Error: Environment variable HONEYCOMB_API_KEY is empty')
  exit(1)

if not dataset:
  print('Error: Environment variable HONEYCOMB_DATASET is empty')
  exit(1)

last_report_time = None
while True:
  headers = {'X-Honeycomb-Team': api_key}
  current_report_time = datetime.datetime.now().astimezone(datetime.timezone.utc)
  args = ['python3', 'events.py']
  if last_report_time:
    args.append(current_report_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ'))

  body = subprocess.check_output(args)

  client = http_client.HTTPSConnection("api.honeycomb.io", timeout=2)
  client.request('POST', '/1/batch/%s' % dataset, body=body, headers=headers)
  resp = client.getresponse()
  print('Report status: %d. Event count: %d' % (resp.code, len(json.loads(body))))
  client.close()

  last_report_time = current_report_time

  # Log every 60 seconds
  time.sleep(60)
