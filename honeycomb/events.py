# Generate all the events to send to honeycomb.
#
# Usage:
#
# All events:
# python3 events.py
#
# Events since timestamp:
# python3 events.py "2021-12-02T14:38:36.551717Z"
# where the timestamp is in UTC

import datetime as datetime
import json
import subprocess
import sys

last_report_time = None
if len(sys.argv) >= 2 and sys.argv[1]:
  last_report_time = datetime.datetime.strptime(sys.argv[1], '%Y-%m-%dT%H:%M:%S.%fZ').replace(tzinfo=datetime.timezone.utc)

ui_session_json = subprocess.check_output(['tilt', 'get', 'uisession', 'Tiltfile', '-o=json'])
ui_session = json.loads(ui_session_json)
tilt_version = ui_session.get('status', {}).get('runningTiltBuild', {}).get('version')
user = ui_session.get('status', {}).get('tiltCloudUsername', '')

ui_resource_list_json = subprocess.check_output(['tilt', 'get', 'uiresources', '-o=json'])
ui_resource_list = json.loads(ui_resource_list_json)

docker_image_list_json = subprocess.check_output(['tilt', 'get', 'dockerimage', '-o=json'])
docker_image_list = json.loads(docker_image_list_json)

custom_build_list = {}
try:
  custom_build_list_json = subprocess.check_output(['tilt', 'get', 'cmdimages', '-o=json'])
  custom_build_list = json.loads(custom_build_list_json)
except (subprocess.CalledProcessError, json.JSONDecodeError):
  pass

current_report_time = datetime.datetime.now().astimezone(datetime.timezone.utc)

events = []

# Always report an updateStatus/runtimeStatus heartbeat for each resource.
items = sorted(ui_resource_list.get('items', []), key=lambda item: item['metadata']['name'])
for item in items:
  events.append({
    'data': {
      'tilt_version': tilt_version,
      'user': user,
      'name': item['metadata']['name'],
      'runtime_status': item['status'].get('runtimeStatus', ''),
      'update_status': item['status'].get('updateStatus', ''),
      'kind': 'uiresource',
    },
    'time': current_report_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ'),
  })

# Report duration times for each Docker Image and custom build
all_images = docker_image_list.get('items', []) + custom_build_list.get('items', [])
builds = sorted(all_images, key=lambda item: item['metadata']['name'])
for build in builds:
  completed = build.get('status', {}).get('completed', None)
  if not completed:
    continue

  start_time = datetime.datetime.strptime(completed['startedAt'], '%Y-%m-%dT%H:%M:%S.%fZ').replace(tzinfo=datetime.timezone.utc)
  end_time = datetime.datetime.strptime(completed['finishedAt'], '%Y-%m-%dT%H:%M:%S.%fZ').replace(tzinfo=datetime.timezone.utc)
  if not last_report_time or end_time > last_report_time:
    events.append({
      'data': {
        'tilt_version': tilt_version,
        'user': user,
        'image_name': build['spec']['ref'],
        'duration_ms': int((end_time - start_time).total_seconds() * 1000),
        'kind': build['kind'].lower(),
      },
      'time': completed['startedAt'],
    })

print(json.dumps(events))
