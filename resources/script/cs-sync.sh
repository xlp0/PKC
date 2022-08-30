#!/bin/bash
SERVICE="rsync"
if pgrep -x "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
else
    echo "$SERVICE stopped"
    # uncomment to start 
    rsync -avP root@toyhouse.wiki:/root/container/* /home/ubuntu/container
    
    # mail
fi