#!/bin/sh



#disable power saving to keep screen running
# settings
# power
# power mode PERFORMANCE
# dim screen UNCHECK
# screen blank OFF

# add the required libraries
sudo apt-get update
sudo apt-get install jq git -y

cd ~/Desktop || exit # fail if it doens't exist something wrong
git clone https://github.com/undoLogic/digi-display.git --branch main --single-branch .

# all the files are now in the desktop


# allow that the run kiosk can run as execute commands
chmod +x runDigiDisplay.sh