#!/usr/bin/env sh
set -eux

# Ensure our monitor will not blank
xset dpms 0 0 0
xset s off
xset -dpms
xset s noblank

#################### VNC ####################
# (e.g., check if x11vnc is installed)
if ! command -v x11vnc &> /dev/null; then
    echo "x11vnc could not be found, please install it."
    exit 1
fi
# Start x11vnc in the background and disown it
echo "Starting x11vnc server..."
x11vnc -usepw -forever -display :0 &
disown %1
echo "x11vnc server started."

# ensure we have a network / internet before loading firefox (avoid not available screens)
while [ "$(hostname)" = "" ]; do
  echo -e "\e[1A\e[KNo network (sleep...) $(date)"
  sleep 2
done
# nixOS did not accept -I argument - future dev
#while [ "$(hostname -I)" = "" ]; do
#  echo -e "\e[1A\e[KNo network (sleep...) $(date)"
#  sleep 2
#done

# close firefox if it is running
if pgrep firefox; then
    # If Firefox is running, close it gracefully
    pkill firefox
    # Wait for a moment to allow Firefox to close
    sleep 2
fi

url=$(jq -r '.url' ~/Desktop/digiDisplay/config.json)
kiosk=$(jq -r '.kiosk' ~/Desktop/digiDisplay/config.json)
echo "running url $url"

if [ $kiosk = true ]; then
  firefox --no-remote --new-instance --kiosk $url
else
  firefox --no-remote --new-instance $url
fi
