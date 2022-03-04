#!/bin/bash
#
# Mediawiki Docker Deployment backup and archiving script for installations on Linux using MySQL.
#
# add dates on each files
# 
################################################################################
## Output command usage
function usage {
    local NAME=$(basename $0)
    echo "Usage: $NAME -d dir -w dir [-s] [-p prefix]"
    echo "       -w <dir>    Path to the destination backup directory. Required."
    echo "       -s          Create a single archive file instead of three"
    echo "                   (images, database, and XML). Optional."
    echo "       -p <prefix> Prefix for the resulting archive file name(s)."
    echo "                   Defaults to the current date in Y-m-d format. Optional."
    echo "       -h          Show this help message. Optional."
}
################################################################################
## Get and validate CLI options
function get_options {
    while getopts 'hcd:w:sp:f' OPT; do
        case $OPT in
            h) usage; exit 1;;
            c) COMPLETE=true;;
            d) BACKUP_DIR=$OPTARG;;
            w) INSTALL_DIR=$OPTARG;;
            s) SINGLE_ARCHIVE=true;;
            p) PREFIX=$OPTARG;;
            f) DEREFERENCE_IMG=true;;
        esac
    done

    ## Check wiki mountpoint directory
    if [ -z "$INSTALL_DIR" ]; then
        echo "Please specify the mountpoint directory with -w" 1>&2
        usage; exit 1;
    fi
    if [ ! -f "$INSTALL_DIR/LocalSettings.php" ]; then
        echo "No LocalSettings.php found in $INSTALL_DIR" 1>&2
        exit 1;
    fi

    INSTALL_DIR=$(cd $INSTALL_DIR; pwd -P)
    echo "Backing up PKC mounted in $INSTALL_DIR"

    ## set to default destination backup folder
    BACKUP_DIR="${INSTALL_DIR}/backup_restore"
    echo "Backing up to $BACKUP_DIR"

    ## set to default LocalSettings.php location
    LOCALSETTINGS="${INSTALL_DIR}/LocalSettings.php"
    echo "LocalSettings file located in $LOCALSETTINGS"

    ## Check and set the archive name prefix
    if [ -z "$PREFIX" ]; then
        PREFIX=$(date +%Y-%m-%d)
        echo "$PREFIX"
    fi

    ## Check whether a single archive file should be created
    if [ "$SINGLE_ARCHIVE" = true ]; then
        echo "Creating a single archive file"
    fi
}
################################################################################
## Add $wgReadOnly to LocalSettings.php
## Kudos to http://www.mediawiki.org/wiki/User:Megam0rf/WikiBackup
function toggle_read_only {
    local MSG="\$wgReadOnly = 'Backup in progress.';"

    # Don't do anything if we can't write to LocalSettings.php
    if [ ! -w "$LOCALSETTINGS" ]; then
        echo "Cannot control read-only mode, aborting" 1>&2
        return 1
    fi

    # Verify if it is already read only
    grep "$MSG" "$LOCALSETTINGS" > /dev/null
    PRESENT=$?

    if [ $1 == "ON" ]; then
        if [ $PRESENT -ne 0 ]; then
            echo "Entering read-only mode"
            grep "?>" "$LOCALSETTINGS" > /dev/null
            if [ $? -eq 0 ];
            then
                sed -i "s/?>/\n$MSG/ig" "$LOCALSETTINGS"
            else
                echo "$MSG" >> "$LOCALSETTINGS"
            fi 
        else
            echo "Already in read-only mode"
        fi
    elif [ $1 == "OFF" ]; then
        # Remove read-only message
        if [ $PRESENT -eq 0 ]; then 
            echo "Returning to write mode"
            sed -i "s/$MSG//ig" "$LOCALSETTINGS"
        else
            echo "Already in write mode"
        fi
    fi
}
################################################################################
## Parse required values out of LocalSetttings.php
function get_localsettings_vars {
    LOCALSETTINGS="$INSTALL_DIR/LocalSettings.php"

    if [ ! -e "$LOCALSETTINGS" ];then
        echo "'$LOCALSETTINGS' file not found."
        return 1
    fi
    echo "Reading settings from '$LOCALSETTINGS'."

    DB_HOST=$(grep '^\$wgDBserver' "$LOCALSETTINGS" | cut -d\" -f2)
    DB_NAME=$(grep '^\$wgDBname' "$LOCALSETTINGS"  | cut -d\" -f2)
    DB_USER=$(grep '^\$wgDBuser' "$LOCALSETTINGS"  | cut -d\" -f2)
    DB_PASS=$(grep '^\$wgDBpassword' "$LOCALSETTINGS"  | cut -d\" -f2)
    DB_PASS=$(grep '^\$wgServer' "$LOCALSETTINGS"  | cut -d\" -f2)
    DOMAIN=
    echo "Logging in to MySQL as $DB_USER to $DB_HOST to backup $DB_NAME"

    # Try to extract default character set from LocalSettings.php
    # but default to binary
    DBTableOptions=$(grep '$wgDBTableOptions' "$LOCALSETTINGS")
    DB_CHARSET=$(echo $DBTableOptions | sed -E 's/.*CHARSET=([^"]*).*/\1/')
    if [ -z $DB_CHARSET ]; then
        DB_CHARSET="binary"
    fi

    echo "Character set in use: $DB_CHARSET."
}
################################################################################
## Dump database to SQL
## Kudos to https://github.com/milkmiruku/backup-mediawiki
function export_sql {
    SQLFILE=$BACKUP_PREFIX_DB"-database.sql.gz"
    echo "Dumping database to $SQLFILE"

#     DOCKER_CMD="mysqldump --all-databases --single-transaction \
# --host=database --default-character-set=$DB_CHARSET \
# --user=root --password=secret > /mnt/backup_restore/mariadb/${PREFIX}-database-${DB_CHARSET}.sql.gz; exit $?"

    DOCKER_CMD="mysqldump --all-databases --single-transaction --host=${DB_HOST} --user=root --password=secret | gzip > /mnt/backup_restore/mariadb/${YOUR_DOMAIN}-${PREFIX}-database.sql.gz; exit $?"

    echo "Previewing docker command: $DOCKER_CMD"
    docker exec -t xlp_mariadb /bin/bash -c "$DOCKER_CMD"

    # Ensure dump worked
    MySQL_RET_CODE=$?
    if [ $MySQL_RET_CODE -ne 0 ]; then
        ERR_NUM=3
        echo "MySQL Dump failed! (return code of MySQL: $MySQL_RET_CODE)" 1>&2
        exit $ERR_NUM
    else
        echo "Database Backup successfully executed ...."
    fi
    RUNNING_FILES="$RUNNING_FILES $SQLFILE"
}

################################################################################
## Export the images directory
function export_images {
    IMG_BACKUP=$YOUR_DOMAIN-$PREFIX"-images.tar.gz"
    echo "Compressing images to $IMG_BACKUP"

    ## Create new diretory
    DOCKER_CMD="mkdir /mnt/backup_restore/mediawiki/$_now"
    # echo $DOCKER_CMD
    docker exec -t xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

    ## Push backup file here
    DOCKER_CMD="php /var/www/html/maintenance/dumpUploads.php | sed 's~mwstore://local-backend/local-public~./images~' | xargs cp -t /mnt/backup_restore/mediawiki/$_now"
    # DOCKER_CMD="php /var/www/html/maintenance/dumpUploads.php | sed -e '/\.\.\//d' -e "/'/d"  | xargs -n 1 cp /mnt/backup_restore/mediawiki/$_now"
    # echo $DOCKER_CMD
    docker exec -t xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

    ## tar everything
    DOCKER_CMD="tar -zcvf $IMG_BACKUP -C /mnt/backup_restore/mediawiki/$_now ."
    # echo $DOCKER_CMD
    docker exec -t -w /mnt/backup_restore/mediawiki xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

    ## delete remaining footprint
    DOCKER_CMD="rm -rf /mnt/backup_restore/mediawiki/$_now"
    echo $DOCKER_CMD
    docker exec -t xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

    IMG_BACKUP=$BACKUP_PREFIX_IMG"-images.tar.gz"
    RUNNING_FILES="$RUNNING_FILES $IMG_BACKUP"
}
################################################################################
## Main

# Preparation
clear
# get_options $@
get_options $@
get_localsettings_vars

# temporary folder
_now=$(date +"%m_%d_%Y_%H%M")

# Get .env
export $(cat .env | grep -v '#' | awk '/=/ {print $1}')

BACKUP_PREFIX=$BACKUP_DIR/$PREFIX
BACKUP_PREFIX_DB="${BACKUP_DIR}/mariadb/${YOUR_DOMAIN}-${PREFIX}"
BACKUP_PREFIX_IMG="${BACKUP_DIR}/mediawiki/${YOUR_DOMAIN}-${PREFIX}"


if [[ "$BASH_SOURCE" == "$0" ]];then
    toggle_read_only ON

    # exporting mysql database
    export_sql
    export_images

    # restarting the dockers
    toggle_read_only OFF

    echo 'Restarting Docker Service'
    docker restart $(docker ps -a -q)

    # Reporting the result here
    echo ""
    echo "##############################################################"
    echo "Backup files created"
    echo "1. MySQL Dump file: $SQLFILE"
    echo "2. Image Media file: $IMG_BACKUP"
    echo "##############################################################"
fi
## End main
################################################################################
