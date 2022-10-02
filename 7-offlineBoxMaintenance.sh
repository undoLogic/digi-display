#!/usr/bin/env bash

# maintenance mode
# ssh tunnel into a random server created on the fly for security (@todo create api generation of servers)
# allowing staff to login to this machine and perform maintenance

MAINTENANCE_SERVER=$(jq -r '.maintenance_server' config.json)
PORT=$(jq -r '.maintenance_server_tunnel_port' config.json)

########################################################################################################################
# setup tunnel REMOTE -> VPS
#@todo create a non root user for higher security access
ssh -R "$PORT":root@localhost:22 "$MAINTENANCE_SERVER"
#eg ssh -R 43022:root@localhost:22 root@maintenance.offlinebox.com

########## then login to VPS and establish tunnel back to REMOTE
# ssh offlinebox@localhost -p 43022