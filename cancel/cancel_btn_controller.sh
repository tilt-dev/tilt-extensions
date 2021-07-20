#!/bin/bash
#
# Starts a controller that watches for new Cmds, and
# creates buttons to cancel them.
#
# We deliberately try to keep this simple to use as a teaching
# tool for how to write controllers.

set -eou pipefail


echo "operator:cancel runs in the background and listens to Tilt

When there are commands to cancel, operator:cancel adds a Cancel button to the Tilt UI
"

# Currently, we only watch Cmds.
tilt get cmd --watch -o name | while read cmd_full_name; do
    cmd_short_name=${cmd_full_name#cmd.tilt.dev/}
    ./reconcile_cancel_btn.sh "$cmd_short_name"
done

                                             
