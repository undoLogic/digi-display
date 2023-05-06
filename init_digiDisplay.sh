#!/bin/sh

# add the required libraries
sudo apt-get update
sudo apt-get install jq git -y

cd ~/Desktop || exit # fail if it doens't exist something wrong
rm -rf ~/Desktop/digiDisplay
#mkdir ~/Desktop/digiDisplay || return # could already exist
#cd ~/Desktop/digiDisplay || exit # fail if it doens't exist something wrong

git clone https://github.com/undoLogic/digi-display.git --branch main --single-branch .

# all the files are now in the desktop (i think it's better to have them out in the open for troubleshooting in the future)

# allow that the run kiosk can run as execute commands
chmod +x runDigiDisplay.sh

echo " =========== NEXT: display power settings so the screen remains active -> settings > power > power mode PERFORMANCE > dim screen UNCHECK > screen blank OFF"
echo " =========== NEXT: add 'runDigiDisplay.sh' to startup applications"