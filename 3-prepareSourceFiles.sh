#!/usr/bin/env bash

github_url=$(jq -r '.github_url' config.json)

# checkout files from github
cd ~/Desktop/offlineBox/sites/primary || exit

# clean directory
rm -rf *

#cd /home/liquidle/www/staging && rm -rf master && git clone git@github.com:undologic/updateCase-undologic.git --branch master --single-branch /home/liquidle/www/staging/master
git clone git@github.com:$github_url.git --branch main --single-branch .

chmod 777 -R *