#!/bin/bash
#
#
# Creating timestamps
echo Job started at "$(date)"

# 1. get my_wiki
WIKI_DB_FILE=$(cd ./mountpoint/backup_restore/mariadb/ &&  ls *my_wiki* -Arth | tail -n 1)
echo Get latest Mediawiki file: $WIKI_DB_FILE

# 2. get image file
IMG_FILE=$(cd ./mountpoint/backup_restore/mediawiki/ && ls *images* -Arth | tail -n 1)
echo Get latest Mediawiki Image file: $IMG_FILE

# 3. Process Restore
echo Running Command
echo ./cs-restore.sh -m ./mountpoint -d $WIKI_DB_FILE -i $IMG_FILE -t my_wiki
./cs-restore.sh -m ./mountpoint -d $WIKI_DB_FILE -i $IMG_FILE -t my_wiki

# 4. Get Matomo
MTM_FILE=$(cd ./mountpoint/backup_restore/mariadb/ && ls *images* -Arth | tail -n 1)
echo Get latest Matomo file: $MTM_FILE
echo ./cs-restore.sh -m ./mountpoint -d $MTM_FILE -i $IMG_FILE -t my_wiki

# 5. Get Gitea
GIT_FILE=$(cd ./mountpoint/backup_restore/mariadb/ && ls *images* -Arth | tail -n 1)
echo Get latest Gitea file: $GIT_FILE
echo ./cs-restore.sh -m ./mountpoint -d $GIT_FILE -i $IMG_FILE -t my_wiki

# 6. Get Keycloak
KCK_FILE=$(cd ./mountpoint/backup_restore/mariadb/ && ls *images* -Arth | tail -n 1)
echo Get latest Keycloak file: $KCK_FILE
echo ./cs-restore.sh -m ./mountpoint -d $KCK_FILE -i $IMG_FILE -t my_wiki
