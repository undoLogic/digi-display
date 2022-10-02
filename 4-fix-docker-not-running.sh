#!/usr/bin/env bash

# issues to restart docker - having issues right now
sudo systemctl daemon-reload #THIS IS RESCUE COMMAND…
sudo systemctl restart docker
sudo systemctl status docker

# if you want to verify the hello world
# docker pull hello-world
##Using default tag: latest
##latest: Pulling from library/hello-world