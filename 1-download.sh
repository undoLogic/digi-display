#!/usr/bin/env bash

# get this file to the new computer
cd ~/
mkdir offlineBox
cd offlineBox
git clone https://github.com/undoLogic/offlinebox.git --branch main --single-branch .

sudo chmod +x -R offlineBox

#wget https://raw.githubusercontent.com/username/repository/branch/path/filename.md
#wget https://raw.githubusercontent.com/undoLogic/offlineBox/main/download.sh