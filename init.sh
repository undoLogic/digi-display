#!/usr/bin/env bash
#cd /home/liquidle/www/staging && rm -rf master && git clone git@github.com:undologic/updateCase-undologic.git --branch master --single-branch /home/liquidle/www/staging/master





# initialize new machine
# Install docker
sudo apt update
sudo apt install curl git

# setup docker the easy way (for now)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker-compose (do I have to do it after docker ?)
sudo apt install docker-compose

# setup keys
cd ~/.ssh
ssh-keygen -t ed25519 -C "you@email.com"
cat id_ed25519.pub

# put public key into github

# checkout files from github
git clone git@github.com:undologic/updateCase-undologic.git --branch master --single-branch sites/domain.com/.


# having issues starting docker