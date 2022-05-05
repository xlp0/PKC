#!/bin/bash
#
# Mediawiki Docker Deployment backup and archiving script for installations on Linux using MySQL.
#
# add dates on each files
# /opt/scripts/cs-backup-image.sh -w /home/ubuntu/cs/mountpoint -p pkc-dev.org -1 pkc-back.org -2 /etc/mysql_backup/id_rsa.pem -3 ubuntu -4 /home/ubuntu/cs/mountpoint/backup_restore/mediawiki
################################################################################
## Output command usage
#
#
function usage {
    local NAME=$(basename $0)
    echo "Usage: $NAME -w dir -p prefix -1 target-host -2 identity-source -3 scp-user -4 scp-dest"
    echo "       -w <dir>    Path to the destination backup directory. Required."
}
################################################################################
## Get and validate CLI options
function get_options {
    while getopts ':w:p:1:2:3:4:' OPT; do
        case $OPT in
            w) INSTALL_DIR=$OPTARG;;
            p) PREFIX=$OPTARG;;
            1) SCP_HOST=$OPTARG;;
            2) SCP_IDENTITY=$OPTARG;;
            3) SCP_USER=$OPTARG;;
            4) SCP_DST=$OPTARG;;
        esac
    done

    echo $INSTALL_DIR
    echo $PREFIX
    echo $SCP_HOST
    echo $SCP_IDENTITY
    echo $SCP_USER
    echo $SCP_DST

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
        PREFIX=$(date +"%F-%Hh%Mm%Ss") 
        echo "$PREFIX"
    else
        PREFIX=${PREFIX}-$(date +"%F-%Hh%Mm%Ss") 
        echo "$PREFIX"
    fi

    ## Check whether a single archive file should be created
    if [ "$SINGLE_ARCHIVE" = true ]; then
        echo "Creating a single archive file"
    fi
}
#
#
################################################################################

function export_images {
    IMG_BACKUP=$PREFIX"-images.tar.gz"
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
    echo $DOCKER_CMD
    docker exec -t -w /mnt/backup_restore/mediawiki xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

    ## delete remaining footprint
    DOCKER_CMD="rm -rf /mnt/backup_restore/mediawiki/$_now"
    echo $DOCKER_CMD
    docker exec -t xlp_mediawiki /bin/bash -c "$DOCKER_CMD"

    # IMG_BACKUP=$BACKUP_PREFIX_IMG"-images.tar.gz"
    RUNNING_FILES="$RUNNING_FILES $IMG_BACKUP"
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
## Transport file to destination
## 
function transport_file {

    SCP='/usr/bin/scp'
    $SCP -i "$SCP_IDENTITY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $INSTALL_DIR/backup_restore/mediawiki/$IMG_BACKUP $SCP_USER@$SCP_HOST:$SCP_DST/$bkp >/dev/null

}

################################################################################
## Main
#
# temporary folder
_now=$(date +"%m_%d_%Y_%H%M")
get_options $@
# toggle_read_only ON
export_images
transport_file
# toggle_read_only OFF

# Reporting the result here
echo ""
echo "##############################################################"
echo "Backup files created"
echo "Image Media file: $IMG_BACKUP"
echo "##############################################################"

## End main
################################################################################
