#!/usr/bin/env bash

# maintenance mode
# ssh tunnel into a random server created on the fly (for security)
# allowing staff to login to this machine and perform maintenance
MAINTENANCE_SERVER="root@192.46.222.20"
PORT=43022

########################################################################################################################
# setup tunnel REMOTE -> VPS
#ssh -R 43022:localhost:22 -i id_rsa root@147.182.145.17

ssh -R $PORT:localhost:22 -i id_rsa $MAINTENANCE_SERVER

#then login to VPS and establish tunnel back to REMOTE
#ssh localhost -p 43022