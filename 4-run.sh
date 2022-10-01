#!/usr/bin/env bash

# general tasks on run
# verify ssh tunnel is active and working

# check our state
STATE=$(jq -r '.state' config.json)

if [ "$STATE" == "RUN" ]; then
  # run
  # start / verify docker is running
  cd ~/Desktop/offlineBox/sites/primary/docker || exit
  # start docker
  ./1reStartDocker.sh
  # this should be moved into a config - what the starting page is
  firefox -kiosk http://localhost/sourceFiles/pages/signage
else
  # do not run
  echo "cannot run as state is $STATE"
fi



