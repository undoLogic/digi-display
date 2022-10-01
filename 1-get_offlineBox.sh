#!/usr/bin/env bash
# this file is offered from http://get.offlinebox.com
# Allowing to start the installation process on the linux ubuntu device

# get this file to the new computer
cd ~/ || exit
mkdir offlineBox || exit
cd offlineBox || exit
git clone https://github.com/undoLogic/offlinebox.git --branch main --single-branch .

# fix permissions @todo find better permissions
sudo chmod 777 -R *
sudo chmod +x -R *

#wget https://raw.githubusercontent.com/username/repository/branch/path/filename.md
#wget https://raw.githubusercontent.com/undoLogic/offlineBox/main/download.sh