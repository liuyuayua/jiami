#!/usr/bin/env bash

set -o errexit

REPO_ROOT=$(git rev-parse --show-toplevel)
DIR="$(cd "$(dirname "$0")" && pwd)"

"$DIR"/install.sh

"$REPO_ROOT"/test/workloads/init.sh
"$DIR"/test-canary.sh
if [ $LOGROUTER_COUNT -gt 0 ]; then
	start_servers $LOGROUTER_COUNT "$STORAGE_TASKSET" router DC3
	# Same number remote/satellite logs and ss as primary
	start_servers $LOGS_COUNT "$LOGS_TASKSET" log DC2
	start_servers $LOGS_COUNT "$LOGS_TASKSET" log DC3
	start_servers $STORAGE_COUNT "$STORAGE_TASKSET" storage DC3
	create_fileconfig
	$CLI "fileconfigure /tmp/fdbfileconfig.json"
	echo "Wait for data to be fully replicated (Healthy), then issue: $CLI configure usable_regions=2"
fi
