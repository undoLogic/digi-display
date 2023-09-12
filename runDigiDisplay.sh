#!/bin/sh

# ensure we have a network / internet before loading firefox (avoid not available screens)
while [ "$(hostname -I)" = "" ]; do
  echo -e "\e[1A\e[KNo network (sleep...) $(date)"
  sleep 2
done


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
