#!/usr/bin/env bash

# general tasks on run
# verify ssh tunnel is active and working

# check our state
STATE=$(jq '.state' config2.json)
echo $STATE

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
  echo "cannot run"
  echo "$STATE"
fi



