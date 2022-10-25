#!/usr/bin/env bash

cd ~/Desktop/offlineBox/sites/primary || exit

# update to the newest version
git git reset --hard origin/master
git pull --force

sudo chmod -R 777 *