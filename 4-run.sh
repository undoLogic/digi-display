#!/usr/bin/env bash

# verify ssh tunnel is active and working

# start / verify docker is running
cd ~/offlineBox || exit
cd sites/domain.com || exit
cd docker || exit

# start docker
./1reStartDocker.sh

# run firefox in kiosk mode with the website from the profile
# firefox –kiosk www.undologic.com/pages/signage

# this should be moved into a config - what the starting page is
firefox -kiosk http://localhost/sourceFiles/pages/signage
