#!/bin/bash
#
# Mediawiki Docker Deployment backup and archiving script for installations on Linux using MySQL.
#
################################################################################
## Output command usage
function usage {
    local NAME=$(basename $0)
    echo "Usage: $NAME -m dir -d file -i file"
    echo "       -m <dir>    path to mountpoint folder, of Cleanslate docker implementation, Required"
    echo "       -d <file>   backup database file, stored in ./mountpoint/backup_restore/mariadb folder, Optional."
    echo "       -i <file>   backup image file, storoed in ./mountpoint/backup_restore/mediawiki folder, Optional."
    echo "       -l          list the available file in backup_restore folder"
    echo ""
    echo "You can restore database, images, or both. Script will process supplied file"
    ## ./cs-restore.sh -m ./mountpoint -d backup-20211003.sql.gz -i backup-image-20211003.tar.gz
}
################################################################################
## Get and validate CLI options
function get_options {
    while getopts 'hm:d:i:' OPT; do
        case $OPT in
            h) usage; exit 1;;
            m) INSTALL_DIR=$OPTARG;;
            d) BACKUP_DB=$OPTARG;;
            i) BACKUP_IMG=$OPTARG;;
        esac
    done

    ## Default, if no parameter is supplied
    if [ -z "$INSTALL_DIR" ]; then
        echo "Please specify the mountpoint directory with -m" 1>&2
        usage; exit 1;
    fi

    ## Check the mountpoint folder
    if [ ! -d "$INSTALL_DIR" ]; then
        echo "No mountpoint folder in $INSTALL_DIR" 1>&2
        exit 1;
    fi

    ## process if one of the backup is specified
    if [ -z "$BACKUP_DB" ] || [ -z "$BACKUP_IMG" ]; then 
        echo "no backup file to restore, terminating script" 1>&2
        exit 1;
    fi

    ## Check the database backup file spec
    if [ -n "$BACKUP_DB" ]; then 
        if [ -f "$INSTALL_DIR/backup_restore/mariadb/$BACKUP_DB" ]; then 
            echo "database backup file found in $INSTALL_DIR/backup_restore/mariadb/$BACKUP_DB"
        else
            echo "database backup file not found in $INSTALL_DIR/backup_restore/mariadb/$BACKUP_DB" 1>&2
            exit 1;
        fi 
    fi 

    ## Check the image backup file spec
    if [ -n "$BACKUP_IMG" ]; then 
        if [ -f "$INSTALL_DIR/backup_restore/mediawiki/$BACKUP_IMG" ]; then 
            echo "image backup file found in $INSTALL_DIR/backup_restore/mediawiki/$BACKUP_IMG"
        else
            echo "image backup file not found in $INSTALL_DIR/backup_restore/mediawiki/$BACKUP_IMG" 1>&2
            exit 1;
        fi 
    fi 
}
################################################################################
## Restoring database
function restore_db {
    DOCKER_CMD="gunzip < /mnt/backup_restore/mariadb/$BACKUP_DB | mysql -u root -h database -psecret; exit $?"

    echo "Previewing docker command: $DOCKER_CMD"
    docker exec -t xlp_mariadb /bin/bash -c "$DOCKER_CMD"

    # Ensure restore worked
    MySQL_RET_CODE=$?
    if [ $MySQL_RET_CODE -ne 0 ]; then
        ERR_NUM=3
        echo "MySQL Dump failed! (return code of MySQL: $MySQL_RET_CODE)" 1>&2
        exit $ERR_NUM
    else
        echo "Database Backup successfully executed ...."
    fi
}
################################################################################
## Restoring images mediawiki
function restore_img {

    # 1. create new folder
    IMG_FOLDER=$(echo "$BACKUP_IMG" | cut -f 1 -d '.')
    DOCKER_CMD="mkdir /mnt/backup_restore/mediawiki/$IMG_FOLDER"
    echo "Previewing docker command: $DOCKER_CMD"
    docker exec -t xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

    # 2. gunzip the images
    DOCKER_CMD="tar -zxf /mnt/backup_restore/mediawiki/$BACKUP_IMG --directory /mnt/backup_restore/mediawiki/$IMG_FOLDER"
    echo "Previewing docker command: $DOCKER_CMD"
    docker exec -t xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

    # 3. run restore script
    DOCKER_CMD="php /var/www/html/maintenance/importImages.php /mnt/backup_restore/mediawiki/$IMG_FOLDER"
    echo "Previewing docker command: $DOCKER_CMD"
    docker exec -t xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

    # delete footprint
    DOCKER_CMD="rm -rf /mnt/backup_restore/mediawiki/$IMG_FOLDER"
    echo "Previewing docker command: $DOCKER_CMD"
    docker exec -t xlp_mediawiki /bin/bash -c "$DOCKER_CMD"
    
}
################################################################################
## Restoring images mediawiki
function update_mw {

    # run update
    DOCKER_CMD="php /var/www/html/maintenance/update.php --quick"
    echo "Previewing docker command: $DOCKER_CMD"
    docker exec -t xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

}
################################################################################
## Main
# Preparation
clear
get_options $@

# temporary folder
_now=$(date +"%m_%d_%Y_%H%M")

BACKUP_PREFIX=$BACKUP_DIR/$PREFIX
BACKUP_PREFIX_DB="${BACKUP_DIR}/mariadb/${PREFIX}"
BACKUP_PREFIX_IMG="${BACKUP_DIR}/mediawiki/${PREFIX}"

if [[ "$BASH_SOURCE" == "$0" ]];then
    # database restore process
    restore_img
    restore_db
    update_mw

    echo 'Restarting Docker Service'
    # docker restart $(docker ps -a -q)

    # Reporting the result here
    echo ""
    echo "##############################################################"
    echo "Restore Process Resume"
    echo "1. MySQL Dump file: $BACKUP_DB is restored"
    echo "2. Image Media file: $BACKUP_IMG is restored"
    echo "##############################################################"
fi
## End main
################################################################################