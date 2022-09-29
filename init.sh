#!/usr/bin/env bash

# get this file to the new computer
mkdir offlineBox
git clone https://github.com/undoLogic/offlinebox.git --branch main --single-branch .


#cd /home/liquidle/www/staging && rm -rf master && git clone git@github.com:undologic/updateCase-undologic.git --branch master --single-branch /home/liquidle/www/staging/master

# initialize new machine
# Install docker
sudo apt update
sudo apt install curl git

# instructions from on lubuntu
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

# setup docker the easy way (for now)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker-compose (do I have to do it after docker ?)
sudo apt install docker-compose

# vmware tools to get copy-paste working
sudo apt-get install open-vm-tools

# setup keys
cd ~/.ssh
ssh-keygen -t ed25519 -C "you@email.com"
cat id_ed25519.pub
# put public key into github

# how to send to updateCase ?
#curl -X POST -H "Content-Type: application/json" -d '{"new-key": "keywouldgohere"}' http://site.updateCase.com/

# checkout files from github
git clone git@github.com:undologic/updateCase-undologic.git --branch master --single-branch sites/domain.com/.

# having issues starting docker
sudo docker-compose up

# issues to restart docker - having issues right now
sudo systemctl daemon-reload #THIS IS RESCUE COMMAND…
sudo systemctl restart docker
sudo systemctl status docker
docker pull hello-world
#Using default tag: latest
#latest: Pulling from library/hello-world
