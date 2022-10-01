#!/usr/bin/env bash

# force upgrade all files of the offlineBox

cd ~/offlineBox || exit
git reset --hard HEAD
git pull
chmod +x *