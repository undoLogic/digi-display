#!/usr/bin/env bash

# this will be run as a crontab

# see if a new config exists for this box ?

# read from our config
MAINTENANCE_ACTIVE=$(jq -r '.maintenance_active' config.json)
echo "maintenance_active is $MAINTENANCE_ACTIVE"
if [ "$MAINTENANCE_ACTIVE" == "true" ]; then
  logger "OfflineBox-CRON: ensure maintenance mode is active"
  ./7-offlineBoxMaintenance.sh
else
  logger "OfflineBox-CRON: IGNORE maintenance mode - ensure autossh is not running"
  pgrep -x autossh | xargs kill -9
fi





RUN=$(jq -r '.run' config.json)
echo "run is $RUN"

if [ "$RUN" == "true" ]; then
  logger "OfflineBox-CRON: ensure run !"
  ./4-run.sh
else
    logger "OfflineBox-CRON: IGNORE run / NOT RUNNING"
fi