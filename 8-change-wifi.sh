#!/usr/bin/env bash

# future feature, ability to update the wifi from a config file to auto provision for a client
# setup the wifi from our config file - not faster then just manually connecting, so will come back to this in the future
# get the wifi adapter name eg #wlp....
ls /sys/class/net
# next modify this file
read -p "Copy the wifi class name"
cd /etc/netplan/
# Edit this file
ls
read -p "Modify the network file above"

# EXAMPLE SETUP
#network:
#    ethernets:
#        eth0:
#            dhcp4: true
#            optional: true
#    version: 2
#    wifis:
#        wlp3s0:
#            optional: true
#            access-points:
#                "SSID-NAME-HERE":
#                    password: "PASSWORD-HERE"
#            dhcp4: true

sudo netplan apply
# if issues do the following
sudo netplan --debug apply

# test ot see it working
ip a