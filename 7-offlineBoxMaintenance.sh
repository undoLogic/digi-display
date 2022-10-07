#!/usr/bin/env bash

# maintenance mode
# ssh tunnel into a random server created on the fly for security (@todo create api generation of servers)
# allowing staff to login to this machine and perform maintenance

MAINTENANCE_SERVER=$(jq -r '.maintenance_server' config.json)
PORT=$(jq -r '.maintenance_server_tunnel_port' config.json)

########################################################################################################################
# setup tunnel REMOTE -> VPS

SERVICE="autossh"
if pgrep -x "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running (use first arg stop if you want to stop)"

    if [ $1 == 'stop' ]
    then
      pkill autossh
      echo "Stopping autossh..."
    fi
else
    echo "$SERVICE stopped - starting up autossh..."

    #@todo create a non root user for higher security access
    logger "Setting up reverse SSH tunnel: ssh -R $PORT:root@localhost:22 $MAINTENANCE_SERVER"

    # @todo autossh not working yet, so trying to get ssh in the background for now
    #ssh -R "$PORT":localhost:22 "$MAINTENANCE_SERVER"

    # @todo get this working
    #autossh -M 20000 -N -R "$PORT":localhost:22 "$MAINTENANCE_SERVER"

    #autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -fN -T -R 10000:localhost:22 console@<myvpnip>
    autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -fN -T -R "$PORT":localhost:22 "$MAINTENANCE_SERVER"
    #autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -fN -T -R 43022:localhost:22 root@ping.offlinebox.com


    #eg ssh -R 43022:root@localhost:22 root@maintenance.offlinebox.com
    #autossh -R 43022:localhost:22 root@maintenance.offlinebox.com

    # uncomment to start nginx if stopped
    # systemctl start nginx
    # mail
fi

########## then login to VPS and establish tunnel back to REMOTE
# ssh offlinebox@localhost -p 43022

