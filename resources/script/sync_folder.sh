#!/bin/bash
SERVICE="rsync"
if pgrep -x "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
else
    echo "$SERVICE stopped"
    # uncomment to start 
    # rsync -avP root@toyhouse.wiki:/root/container/* /home/ubuntu/container
    rsync -PazSHAX --rsh "ssh -i /home/ubuntu/.ssh/OregonCluster.pem" --rsync-path "sudo rsync" /home/ubuntu/Cleanslate/docker_dep/mountpoint/images/* ubuntu@pkc-mirror.org:/home/ubuntu/cs/mountpoint/images/
    # mail
fi