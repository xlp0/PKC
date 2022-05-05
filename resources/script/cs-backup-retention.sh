#!/bin/bash
#
# Mediawiki Docker Deployment backup and archiving script for installations on Linux using MySQL.
#
# shell script to delete backup file older than x days
# 
# usage: ./cs-backup-retension.sh 5
# - delete file older than 5 days
################################################################################
## Output command usage
function usage {
    local NAME=$(basename $0)
    echo "Usage: $NAME -d num-of-days" 
    echo "       -d num-of-days    "
    echo "Delete backup file older than num-of-days"
}
function get_options {
    while getopts 'd:' OPT; do
        case $OPT in
            d) NUM_OF_DAYS=$OPTARG;;
        esac
    done

    ## Default, if no parameter is supplied
    if [ -z "$NUM_OF_DAYS" ]; then
        echo "Please specify number of days" 1>&2
        usage; exit 1;
    fi
}

################################################################################
## Restoring images mediawiki
function exec_delete {

    echo "deleting database backup older that $NUM_OF_DAYS older"
    echo "find ./mountpoint/backup_restore/mariadb/* -mtime +$NUM_OF_DAYS -exec rm {} \;"

    echo "deleting image backup older that $NUM_OF_DAYS older"
    echo "find ./mountpoint/backup_restore/mediawiki/* -mtime +$NUM_OF_DAYS -exec rm {} \;"

}

##
################################################################################
## Main
get_options $@
exec_delete

## End main
################################################################################
