#!/usr/bin/env sh
# this is the manual command. This will run with the autoscript runDigiDisplay.sh that is loaded to the startup of the computer
set -eux
xset dpms 0 0 0
xset s off
xset -dpms
xset s noblank