#!/usr/bin/env bash

# vmware tools to get copy-paste working
# sudo apt-get install open-vm-tools

#setup the wifi from our config file
#get the wifi adapter name eg #wlp....
ls /sys/class/net
# next modify this file
read -p "Copy the wifi class name"
cd /etc/netplan/
# Edit this file
ls
read -p "Modify the network file above"

# EXAMPLE SETUP
#network:
#    ethernets:
#        eth0:
#            dhcp4: true
#            optional: true
#    version: 2
#    wifis:
#        wlp3s0:
#            optional: true
#            access-points:
#                "SSID-NAME-HERE":
#                    password: "PASSWORD-HERE"
#            dhcp4: true

sudo netplan apply
# if issues do the following
sudo netplan --debug apply

# test ot see it working
ip a




# Install Docker
sudo apt update
sudo apt install curl git openssh-server

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

# allow to run as non-root
sudo usermod -aG docker offlinebox

newgrp docker

# setup keys
cd ~/.ssh || exit
ssh-keygen -t ed25519 -C "support@offlinebox.com"
cat id_ed25519.pub
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

############# SSH tunnel

# first time start it up
sudo systemctl start sshd
# startup at reboot - not working
sudo systemctl enable sshd


# create crontab

# restart the computer so we can have docker commands without sudo
sudo shutdown -r now