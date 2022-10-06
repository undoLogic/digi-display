#!/usr/bin/env bash

if [ -z $1 ]
then
  INSTALL_SOFTWARE=true
  UPDATE_COMPUTER_SETTINGS=true
  SETUP_KEYS=true
  INSTALL_DOCKER=true
  DOCKER_ROOTLESS=false
  INSTALL_DOCKER_COMPOSE=true
  INSTALL_SSH_TUNNEL=true
  CREATE_CRON=true
  RESTART=false
else
  # future add ability to use $1 to choose a specific to run
  echo "Not Implemented Yet"
fi

# ======================================================================= Install software
if $INSTALL_SOFTWARE
then
  sudo apt update
  logger "Installing: curl git openssh-server jq autossh uidmap"
  sudo apt install -y curl git openssh-server jq autossh uidmap
  # vmware tools to get copy-paste working
  # sudo apt-get install open-vm-tools
fi

# ======================================================================= Update Browser Settings
if $UPDATE_COMPUTER_SETTINGS
then
  # keep the screen running without turning off
  # On Ubuntu 20.04.1 LTS you can click on the power button on the top right of your screen, then "Settings",
  # then "Power", then select the "Never" option from the "Blank Screen" drop down.
  logger "Disabling auto lock on computer"
  gsettings set org.gnome.desktop.screensaver lock-enabled false
fi
# ======================================================================= SSH keys
if $SETUP_KEYS
then
  # setup keys
  logger "OfflineBox: setting up SSH-KEYS"
  cd ~/.ssh || exit
  ssh-keygen -t ed25519 -C "support@offlinebox.com"
  cat id_ed25519.pub
  NEW_KEY="$(cat ~/.ssh/id_ed25519.pub)"
  echo $NEW_KEY
  NEW_KEY_CLEAN2=$(echo $NEW_KEY | tr ' ' '_' | tr '\n' ' ')
  echo $NEW_KEY_CLEAN2
  #send keys to our server
  curl -X POST -H "Content-Type: application/json" --data-binary "{\"ssh-key\": \"$NEW_KEY_CLEAN2\"}"  https://site.updatecase.com/pages/addNewDevice
  logger "OfflineBox: sent new key to server"
fi


# ===========================================================================================
if $INSTALL_SSH_TUNNEL
then
  # first time start it up
  sudo systemctl start sshd
  # startup at reboot - not working
  sudo systemctl enable sshd
fi


# ====================================================================== Docker
# setup docker the easy way (for now)

if $INSTALL_DOCKER
then
  logger "OfflineBox: setting up Docker"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
fi

# ================================================================= Install Docker Compose
if $INSTALL_DOCKER_COMPOSE
then
  # Docker-compose (do I have to do it after docker ?)
  logger "OfflineBox: setting up Docker-compose"
  sudo apt install -y docker-compose
fi

# ================================================================= Cron
if $CREATE_CRON
then
  # create crontab
  logger "will figure out how to install crontab here"
fi

# ===================================================================== docker rootless
if $DOCKER_ROOTLESS
then
  logger "OfflineBox: setting up rootless mode for docker"
  # run in rootless mode (no sudo)
  dockerd-rootless-setuptool.sh install
  # allow to run as non-root
  sudo usermod -aG docker offlinebox
  newgrp docker
fi

# ================================================================= Restart
if $RESTART
then
  # restart the computer so we can have docker commands without sudo
  sudo shutdown -r now
fi