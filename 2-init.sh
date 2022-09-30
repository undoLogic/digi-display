#!/usr/bin/env bash

# vmware tools to get copy-paste working
# sudo apt-get install open-vm-tools

# Install Docker
sudo apt update
sudo apt install curl git

# instructions from on lubuntu
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

# setup docker the easy way (for now)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# run in rootless mode (no sudo)
dockerd-rootless-setuptool.sh install

# if errors do this
#sudo sh -eux <<EOF
## Install newuidmap & newgidmap binaries
#apt-get install -y uidmap
#EOF

# Docker-compose (do I have to do it after docker ?)
sudo apt install docker-compose

# setup keys
cd ~/.ssh
ssh-keygen -t ed25519 -C "support@offlinebox.com"
#cat id_ed25519.pub
echo "FUTURE: save into to server automatically"
# put public key into github

# Check into updateCase and give SSH key and computer name
#curl -X POST -H "Content-Type: application/json" -d '{"new-key": "keywouldgohere"}' http://site.updateCase.com/

# issues to restart docker - having issues right now
#sudo systemctl daemon-reload #THIS IS RESCUE COMMAND…
#sudo systemctl restart docker
#sudo systemctl status docker
#docker pull hello-world
##Using default tag: latest
##latest: Pulling from library/hello-world

# setup SSH tunnel

# create crontab
