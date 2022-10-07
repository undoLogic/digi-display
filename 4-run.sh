#!/usr/bin/env bash

# @todo check if docker is already running
if pgrep -x "firefox" > /dev/null
then

      logger "offlineBox: Starting firefox"
      # start / verify docker is running
      cd ~/Desktop/offlineBox/sites/primary/docker/ || exit
      # start docker
      ./1reStartDocker.sh
      # this should be moved into a config - what the starting page is

      #make sure it is closed as if it is open only a new tab will open
      # shellcheck disable=SC2046
      kill -9 $(ps -x | grep firefox)

      firefox -kiosk http://localhost/sourceFiles/pages/signage
else
      echo "Firefox running"
      logger "offlineBox: Firefox already running"
fi