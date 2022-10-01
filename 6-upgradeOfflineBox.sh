#!/usr/bin/env bash

# force upgrade all files of the offlineBox
cd ~/Desktop/offlineBox || exit

#since we are changing permissions, we need to do a hard reset @todo figure out a better way
git reset --hard HEAD
git pull
chmod +x *