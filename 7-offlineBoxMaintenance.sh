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
    echo "$SERVICE is already running"
else
    echo "$SERVICE stopped - starting up autossh..."

    #@todo create a non root user for higher security access
    logger "Setting up reverse SSH tunnel: ssh -R $PORT:root@localhost:22 $MAINTENANCE_SERVER"
    #ssh -R "$PORT":root@localhost:22 "$MAINTENANCE_SERVER"
    autossh -f -R -N "$PORT":root@localhost:22 "$MAINTENANCE_SERVER"
    #eg ssh -R 43022:root@localhost:22 root@maintenance.offlinebox.com
    #autossh -R 43022:localhost:22 root@maintenance.offlinebox.com

    # uncomment to start nginx if stopped
    # systemctl start nginx
    # mail
fi







########## then login to VPS and establish tunnel back to REMOTE
# ssh offlinebox@localhost -p 43022