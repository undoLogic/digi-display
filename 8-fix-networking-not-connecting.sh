#!/usr/bin/env bash

sudo nmcli device status
sudo nmcli networking off
sudo nmcli networking on
sudo nmcli device status