#!/usr/bin/env bash
# this file is offered from http://get.offlinebox.com
# Allowing to start the installation process on the linux ubuntu device

sudo apt update
sudo apt install git

# get this file to the new computer
mkdir ~/Desktop/offlineBox || return
cd ~/Desktop/offlineBox || exit
git clone https://github.com/undoLogic/offlinebox.git --branch main --single-branch .

# fix permissions @todo find better permissions
sudo chmod 777 -R *
sudo chmod +x -R *

cd ~/Desktop/offlineBox || exit

#wget https://raw.githubusercontent.com/username/repository/branch/path/filename.md
#wget https://raw.githubusercontent.com/undoLogic/offlineBox/main/download.sh