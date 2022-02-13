#!/bin/bash
#
# run backup script on this server
./cs-backup.sh -w ./mountpoint -p auto
# delete file older than XX days

# call ansible to copy to remote server and run restore script.
ansible-playbook -i ./cs-remote-host ./cs-offsite-restore.yml