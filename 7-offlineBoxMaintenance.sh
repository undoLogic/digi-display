#!/usr/bin/env bash
# maintenance mode
# allowing staff to login to this machine and perform maintenance
MAINTENANCE_SERVER=$(jq -r '.maintenance_server' config.json)
PORT=$(jq -r '.maintenance_server_tunnel_port' config.json)
SERVICE="autossh"
if pgrep -x "$SERVICE" >/dev/null
then
  if [ "$1" == 'stop' ]
  then
    pkill autossh
    logger -s "OfflineBox: SHUTTING DOWN Maintenance server"
  else
    logger -s "OfflineBox: Maintenance server already running (use first arg 'stop' if you want to stop)"
  fi
else
  if [ "$1" == 'stop' ]
  then
    logger -s "OfflineBox: Already shutdown"
  else
    logger -s "OfflineBox: Starting MAINTENANCE_SERVER - Setting up reverse SSH tunnel: ssh -R $PORT:root@localhost:22 $MAINTENANCE_SERVER"
    #@todo create a non root user for higher security access
    #autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -fN -T -R 10000:localhost:22 console@<myvpnip>
    autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -fN -T -R "$PORT":localhost:22 "$MAINTENANCE_SERVER"
    ########## then login to VPS and establish tunnel back to REMOTE
    # ssh offlinebox@localhost -p 43022
    # Manual reverse tunnel
    #ssh -R "$PORT":localhost:22 "$MAINTENANCE_SERVER"
  fi
fi