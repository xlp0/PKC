#! /bin/bash

# Check if docker is installed or not
if [[ $(which docker) && $(docker --version) ]]; then
  echo "$OSTYPE has $(docker --version) installed"
  else
    echo "You need to Install docker"
    # command
    case "$OSTYPE" in
      darwin*)  echo "$OSTYPE should install Docker Desktop by following this link https://docs.docker.com/docker-for-mac/install/" ;; 
      msys*)    echo "$OSTYPE should install Docker Desktop by following this link https://docs.docker.com/docker-for-windows/install/" ;;
      cygwin*)  echo "$OSTYPE should install Docker Desktop by following this link https://docs.docker.com/docker-for-windows/install/" ;;
      linux*)
        echo "Some $OSTYPE distributions could install Docker, we will try to install Docker for you..." 
        ./AdvancedTooling/installDockerForUbuntu.sh   
        echo "Installation complete, setting up the sudo su command, you will need the root access to this linux machine."
        sudo su ;;
      *)        echo "Sorry, this $OSTYPE might not have Docker implementation" ;;
    esac
fi

# Make sure that the docker-compose.yml is available in this directory, otherwise, download it.
if [ ! -e ./docker-compose.yml ]; then
  curl https://raw.githubusercontent.com/xlp0/XLPWikiMountPoint/main/docker-compose.yml > docker-compose.yml
fi

# Make sure that LocalSettings.php is available in this directory, otherwise, download it.
if [ ! -e ./LocalSettings.php ]; then
  curl https://raw.githubusercontent.com/xlp0/XLPWikiMountPoint/main/LocalSettings.php > LocalSettings.php
fi


if [ -f .env ]; then
    # Load Environment Variables
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
    # For instance, will be example_kaggle_key
    echo "Loaded environmental variable: TRANSPORT_STRING=$TRANSPORT_STRING"
    echo "Loaded environmental variable: HOST_STRING=$HOST_STRING"
    echo "Loaded environmental variable: PortNumber=$PortNumber"
    echo "Loaded environmental variable: OAUTH_CLIENT_ID=$OAUTH_CLIENT_ID"
    #Secret will not show
    echo "Loaded environmental variable: OAUTH_CLIENT_SECRET=********"

    if [[ ${TRANSPORT_STRING} =~  .*https.* ]]; then
      echo "To use the following transport string:  ${TRANSPORT_STRING}://$HOST_STRING"
      replaceString="$HOST_STRING";
    else
      echo "To use the following transport string:  ${TRANSPORT_STRING}://$HOST_STRING:$PortNumber"
      replaceString="$HOST_STRING:$PortNumber";
    fi


    # Localhost configuration based on .env
    # Substitute to correct config if founded "$TargetKey =" in LocalSetting.php
    # Only replace 'var' instead of "var" 
    filename="LocalSettings.php"
    # Put in all the params for configuration
    oauth_key_array=(
      "wgServer" 
      "wgOAuth2Client\[\'client\'\]\[\'id\'\]" 
      "wgOAuth2Client\[\'client\'\]\[\'secret\'\]"
      "wgOAuth2Client\[\'configuration\'\]\[\'redirect_uri\'\]"
      )

    oauth_val_array=(
      $TRANSPORT_STRING://${replaceString} 
      $OAUTH_CLIENT_ID 
      $OAUTH_CLIENT_SECRET
      "$TRANSPORT_STRING://${replaceString}/index.php/Special:OAuth2Client/callback"
      )
    len=${#oauth_key_array[@]}
    for (( i=0; i<$len; i++ ));
    do
      echo "Replacing string in LocalSettings.php: ${oauth_key_array[$i]}"
        sed "s|\$${oauth_key_array[$i]}[[:blank:]]*=.*|\$${oauth_key_array[$i]} = \"${oauth_val_array[$i]}\";|" $filename > temp.txt && mv temp.txt $filename
    done
fi

echo "Please type in the Administrative(root) password of the machine that you are installing PKC service when asked... "





# If docker is running already, first run a data dump before shutting down docker processes
# One can use the following instruction to find the current directory name withou the full path
# CURRENTDIR=${PWD##*/}
# In Bash v4.0 or later, lower case can be obtained by a simple ResultString="${OriginalString,,}"
# See https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash
# However, it will not work in Mac OS X, since it is still using Bash v 3.2
LOWERCASE_CURRENTDIR="$(tr [A-Z] [a-z] <<< "${PWD##*/}")"
MW_CONTAINER=$LOWERCASE_CURRENTDIR"_mediawiki_1"
DB_CONTAINER=$LOWERCASE_CURRENTDIR"_database_1"

# This variable should have the same value as the variable $wgResourceBasePath in LocalSettings.php
# ResourceBasePath="/var/www/html"

# BACKUPSCRIPTFULLPATH=$ResourceBasePath"/extensions/BackupAndRestore/backup.sh"
# RESOTRESCRIPTFULLPATH=$ResourceBasePath"/extensions/BackupAndRestore/restore.sh"

# echo "Executing: " docker exec $MW_CONTAINER $BACKUPSCRIPTFULLPATH
# docker exec $MW_CONTAINER $BACKUPSCRIPTFULLPATH
# stop all docker processes
docker-compose down --volumes

# If the mountPoint directory doesn't exist, 
# Decompress the InitialDataPackage to ./mountPoint 
if [ ! -e ./mountPoint/ ]; then

if [ ! -e ./InitialContentPackage.tar.gz ]; then 
  curl  https://raw.githubusercontent.com/xlp0/XLPWikiMountPoint/main/InitialContentPackage.tar.gz > temp.tar.gz
fi
  tar -xzvf ./temp.tar.gz -C .
  if [ -e ./temp.tar.gz ]; then 
    rm ./temp.tar.gz
  fi
fi

# Start the docker processes
sudo docker-compose up -d --build


# After docker processes are ready, reload the data from earlier dump
# echo "Loading data from earlier backups..."
# echo "Executing: " docker exec $MW_CONTAINER $RESOTRESCRIPTFULLPATH
# docker exec $MW_CONTAINER $RESOTRESCRIPTFULLPATH

echo $MW_CONTAINER" will do regular database content dump."
docker exec $MW_CONTAINER service cron start

# Give read/write access to all users for the images directory.
docker exec $MW_CONTAINER chmod -R 777 /var/www/html/images

docker exec $MW_CONTAINER php /var/www/html/maintenance/update.php

echo "Please go to a browser and use http://$HOST_STRING:$PortNumber to test the service"