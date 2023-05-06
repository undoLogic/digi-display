#!/bin/sh

# ensure we have a network / internet before loading firefox (avoid not available screens)
while [ "$(hostname -I)" = "" ]; do
  echo -e "\e[1A\e[KNo network (sleep...) $(date)"
  sleep 2
done

url=$(jq -r '.url' config.json)
# firefox --kiosk $url
firefox $url