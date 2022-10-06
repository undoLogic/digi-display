#!/usr/bin/env bash

# add the nameserver 8.8.8.8 in resolve.conf
read -p "comment out nameserver and add 'nameserver 8.8.8.8'"
sudo vi /etc/resolv.conf

# issues to restart docker - having issues right now
sudo systemctl daemon-reload #THIS IS RESCUE COMMAND…
sudo systemctl restart docker
sudo systemctl status docker
docker pull hello-world
# if you want to verify the hello world

##Using default tag: latest
##latest: Pulling from library/hello-world