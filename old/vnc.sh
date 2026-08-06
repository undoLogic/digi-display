#!/usr/bin/env sh
# this is the manual command. This will run with the autoscript runDigiDisplay.sh that is loaded to the startup of the computer
set -eux
x11vnc -usepw -forever -display :0 &
disown %1