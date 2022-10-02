#!/usr/bin/env bash

# this will be run as a crontab

# read from our config
MAINTENANCE_ACTIVE=$(jq -r '.maintenance_active' config.json)

if [ "$MAINTENANCE_ACITVE" == true ]; then
  logger "OfflineBox-CRON: ensure maintenance mode is active"
  ./7-offlinBoxMaintenance.sh
else
    logger "OfflineBox-CRON: IGNORE maintenance mode"
fi

RUN=$(jq -r '.run' config.json)


if [ "$MAINTENANCE_ACITVE" == true ]; then
  logger "OfflineBox-CRON: ensure run !"
  ./7-offlinBoxMaintenance.sh
else
    logger "OfflineBox-CRON: IGNORE run / disabled"
fi