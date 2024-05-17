#!/bin/sh

# add the required libraries
sudo apt-get update
sudo apt-get install jq git curl net-tools -y

# upgrade to latest security updates
sudo apt-get upgrade

cd ~/Desktop || exit # fail if it doens't exist something wrong
rm -rf ~/Desktop/digiDisplay
mkdir ~/Desktop/digiDisplay || return # could already exist
cd ~/Desktop/digiDisplay || exit # fail if it doens't exist something wrong

git clone https://github.com/undoLogic/digi-display.git --branch main --single-branch .

# allow that the run kiosk can run as execute commands
chmod +x runDigiDisplay.sh

echo " =========== NEXT follow the instructions on www.digi-display.com -> source code"
