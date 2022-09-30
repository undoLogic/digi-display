#!/usr/bin/env bash

# checkout files from github
cd ~/offlineBox
cd sites/domain.com
#cd /home/liquidle/www/staging && rm -rf master && git clone git@github.com:undologic/updateCase-undologic.git --branch master --single-branch /home/liquidle/www/staging/master
git clone git@github.com:undologic/updateCase-undologic.git --branch master --single-branch .

cd docker
# having issues starting docker (how to get non sudo)
sudo docker-compose up