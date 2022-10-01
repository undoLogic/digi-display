#!/usr/bin/env bash

# checkout files from github
cd ~/offlineBox || exit
cd sites/domain.com || exit

#cd /home/liquidle/www/staging && rm -rf master && git clone git@github.com:undologic/updateCase-undologic.git --branch master --single-branch /home/liquidle/www/staging/master
git clone git@github.com:undologic/updateCase-undologic.git --branch master --single-branch .


