#!/usr/bin/env bash

# vmware tools to get copy-paste working
# sudo apt-get install open-vm-tools

# Install Docker
sudo apt update
sudo apt install curl git openssh-server jq


# setup keys
echo "====================================== Setting up SSH-KEYS =========================="
cd ~/.ssh || exit
ssh-keygen -t ed25519 -C "support@offlinebox.com"
cat id_ed25519.pub
NEW_KEY="$(cat ~/.ssh/id_ed25519.pub)"
echo $NEW_KEY
NEW_KEY_CLEAN2=$(echo $NEW_KEY | tr ' ' '_' | tr '\n' ' ')
echo $NEW_KEY_CLEAN2
#send keys to our server
curl -X POST -H "Content-Type: application/json" --data-binary "{\"ssh-key\": \"$NEW_KEY_CLEAN2\"}"  https://site.updatecase.com/pages/addNewDevice





# setup docker the easy way (for now)
echo "====================================== Setting up Docker =========================="
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh


echo "====================================== Setting up rootless mode for docker ======="
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

## keep the screen running without turning off @todo edit the power options
# On Ubuntu 20.04.1 LTS you can click on the power button on the top right of your screen, then "Settings", then "Power", then select the "Never" option from the "Blank Screen" drop down.

# create crontab

# restart the computer so we can have docker commands without sudo
sudo shutdown -r now