#!/usr/bin/env bash

INSTALL_SOFTWARE=true
UPDATE_COMPUTER_SETTINGS=false
SETUP_KEYS=false
INSTALL_DOCKER=false
DOCKER_ROOTLESS=false
INSTALL_DOCKER_COMPOSE=false
INSTALL_SSH_TUNNEL=false
CREATE_CRON=false
RESTART=false

# ======================================================================= Install software
if $INSTALL_SOFTWARE
then
  sudo apt update
  sudo apt install curl git openssh-server jq autossh
  # vmware tools to get copy-paste working
  # sudo apt-get install open-vm-tools
fi

# ======================================================================= Update Browser Settings
if $UPDATE_COMPUTER_SETTINGS
then
  # keep the screen running without turning off
  # On Ubuntu 20.04.1 LTS you can click on the power button on the top right of your screen, then "Settings",
  # then "Power", then select the "Never" option from the "Blank Screen" drop down.
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
# ====================================================================== Docker
# setup docker the easy way (for now)

if $INSTALL_DOCKER
then
  logger "OfflineBox: setting up Docker"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
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
  # if errors do this
  #sudo sh -eux <<EOF
  ## Install newuidmap & newgidmap binaries
  #apt-get install -y uidmap
  #EOF
fi

# ===========================================================================================
if $INSTALL_DOCKER_COMPOSE
then
  # Docker-compose (do I have to do it after docker ?)
  logger "OfflineBox: setting up Docker-compose"
  sudo apt install docker-compose
fi

# ===========================================================================================
if $INSTALL_SSH_TUNNEL
then
  # first time start it up
  sudo systemctl start sshd
  # startup at reboot - not working
  sudo systemctl enable sshd
fi
############# SSH tunnel

if $CREATE_CRON
then
  # create crontab
  logger "will figure out how to install crontab here"
fi

if $RESTART
then
  # restart the computer so we can have docker commands without sudo
  sudo shutdown -r now
fi
