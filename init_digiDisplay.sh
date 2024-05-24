#!/bin/sh

# Check if apt is installed
if command -v apt &> /dev/null
then
    echo "apt is installed - Installing updates"
    # You can add more commands here that you want to run if apt is installed
    # add the required libraries
    sudo apt-get update
    sudo apt-get install jq git curl net-tools -y

    # remove screensaver so it will not blank screen at all
    sudo apt purge xscreensaver

    # upgrade to latest security updates
    sudo apt-get upgrade

else
    echo "Probably a NixOS installation, skipping updates"
    # You can add more commands here that you want to run if apt is not installed
fi

# Create the directories on the Desktop for all the files
cd ~/Desktop || exit # fail if it doens't exist something wrong
rm -rf ~/Desktop/digiDisplay # remove if already exists
mkdir ~/Desktop/digiDisplay || return # could already exist
cd ~/Desktop/digiDisplay || exit # fail if it doens't exist something wrong

git clone https://github.com/undoLogic/digi-display.git --branch main --single-branch .

# allow that the run kiosk can run as execute commands
chmod +x runDigiDisplay.sh

echo " - - - "
echo " =========== NEXT follow the instructions on www.digi-display.com -> source code"
