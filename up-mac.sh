#! /bin/bash
################################################################################
## Output command usage
function usage {
    local NAME=$(basename $0)
    echo "Usage: $NAME <file>"
    echo "       <file> Host file, listing of installation target server."
}

function prep_nginx {
    # sed -i 's/old-text/new-text/g' input.txt
    echo "Preparing NGINX Config Files ..."
    # 
    sed "s/#GIT_SUBDOMAIN/$GITEA_SUBDOMAIN/g" ./config-template/git.conf > ./config/git.conf
    sed "s/#PMA_SUBDOMAIN/$PMA_SUBDOMAIN/g" ./config-template/pma.conf > ./config/pma.conf
    sed "s/#MTM_SUBDOMAIN/$MTM_SUBDOMAIN/g" ./config-template/mtm.conf > ./config/mtm.conf
    sed "s/#VS_SUBDOMAIN/$VS_SUBDOMAIN/g" ./config-template/vs.conf > ./config/vs.conf
    sed "s/#YOUR_DOMAIN/$YOUR_DOMAIN/g" ./config-template/reverse-proxy.conf > ./config/reverse-proxy.conf
    sed "s/#YOUR_DOMAIN/$YOUR_DOMAIN/g" ./config-template/pkc.conf > ./config/pkc.conf
    echo ""
}

function prep_mw {
    echo "Prepare LocalSettings.php file"
    if [ "$YOUR_DOMAIN" = "localhost" ]; then 
        FQDN="$DEFAULT_TRANSPORT://$YOUR_DOMAIN:$PORT_NUMBER"
        KCK_AUTH_FQDN="$DEFAULT_TRANSPORT://$YOUR_DOMAIN:$KCK_PORT_NUMBER"
        MTM_FQDN="$DEFAULT_TRANSPORT://$YOUR_DOMAIN:$MATOMO_PORT_NUMBER"
        GIT_FQDN="$DEFAULT_TRANSPORT://$YOUR_DOMAIN:$GITEA_PORT_NUMBER"
    else
        FQDN="$DEFAULT_TRANSPORT://www.$YOUR_DOMAIN"
    fi
    #
    sed "s|#MTM_FQDN|$MTM_FQDN|g" ./config-template/LocalSettings-Local.php > ./config/LocalSettings.php
    sed -i '' "s|#YOUR_FQDN|$FQDN|g" ./config/LocalSettings.php
    sed -i '' "s|#KCK_SUBDOMAIN|$KCK_AUTH_FQDN|g" ./config/LocalSettings.php
    #
    sed "s|#MTM_SUBDOMAIN|$MTM_FQDN|g" ./config-template/config.ini.php > ./config/config.ini.php
    #
    sed "s|#YOUR_KCK_FQDN|$KCK_AUTH_FQDN|g" ./config-template/update-mtm-config.sql > ./config/update-mtm-config.sql
    #
    sed "s|#GIT_FQDN|$GIT_FQDN|g" ./config-template/app.ini > ./config/app.ini
}

function prep_local {
    # 
    # extracting mountpoint
    tar -xvf mountpoint.tar.gz
    # copy LocalSettings.php
    echo "Applying Localhost setting .... "
    cp ./config/LocalSettings.php ./mountpoint/LocalSettings.php
    cp ./config/config.ini.php-local ./mountpoint/matomo/config/config.ini.php
    # config/app.ini
    cp ./config/app.ini ./mountpoint/gitea/gitea/conf/app.ini
    cp ./config/update-mtm-config.sql ./mountpoint/backup_restore/mariadb/update-mtm-config.sql
}
################################################################################
## Main
# Preparation
# 
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
    if [ "$YOUR_DOMAIN" == "localhost" ]; then {
        GITEA_SUBDOMAIN=$YOUR_DOMAIN:$GITEA_PORT_NUMBER
        PMA_SUBDOMAIN=$YOUR_DOMAIN:$PHP_MA
        MTM_SUBDOMAIN=$YOUR_DOMAIN:$MATOMO_PORT_NUMBER
        VS_SUBDOMAIN=$YOUR_DOMAIN:$VS_PORT_NUMBER
        KCK_SUBDOMAIN=$YOUR_DOMAIN:$KCK_PORT_NUMBER
    } else {
        GITEA_SUBDOMAIN=git.$YOUR_DOMAIN
        PMA_SUBDOMAIN=pma.$YOUR_DOMAIN
        MTM_SUBDOMAIN=mtm.$YOUR_DOMAIN
        VS_SUBDOMAIN=code.$YOUR_DOMAIN
        KCK_SUBDOMAIN=$YOUR_DOMAIN:$KCK_PORT_NUMBER
    }
    fi
    # Displays installation plan
    echo "--------------------------------------------------------"
    echo "Installation Plan:"
    echo "Ansible script to install on host file: $1"
    echo ""
    echo "Loaded environmental variable: "
    echo "Port number for Mediawiki: $PORT_NUMBER"
    echo "Port number for Matomo Service: $MATOMO_PORT_NUMBER"
    echo ""
    echo ""
    echo "If you have installed Dockers, please ensure your"
    echo "Docker desktop is running."
    echo ""
    read -p "Press [Enter] key to continue..."
    echo "--------------------------------------------------------"
else
    echo ".env files not found, please provide the .env file"
    exit 1;
fi
# Display execution time
date
#
#
# Pre-Requisite, install docker
docker info | grep -q docker-desktop && echo "Docker is found, not installing..." || brew install --cask docker
# 
# prepares config file
# 1. NGINX Config Files
# read -p "Prep nginx Press [Enter] key to continue..."
# prep_nginx
# 2. LocalSettings.php files
read -p "Prep Mediawiki configuration Press [Enter] key to continue..."
echo ""
echo ""
prep_mw
#
# is this localhost implementation?
echo "$YOUR_DOMAIN"
if [ "$YOUR_DOMAIN" == "localhost" ]; then
    read -p "Preparing Mediawiki for Local Installation, Press [Enter] key to continue..."
    # copy files to cs folder
    prep_local
fi
#
echo "Continue to install all docker images"
echo ""
echo ""
#
# try to remove all available docker image, start zero
# docker rmi $(docker images -a -q)
# Loading all images
# read -p "Press [Enter] to Load Images..."
# docker load -i ./docker-image/xlp_codeserver.tar.gz
# docker load -i ./docker-image/xlp_gitea.tar.gz
# docker load -i ./docker-image/xlp_mariadb.tar.gz
# docker load -i ./docker-image/xlp_matomo.tar.gz
# docker load -i ./docker-image/xlp_mediawiki.tar.gz
# docker load -i ./docker-image/xlp_phpmyadmin.tar.gz
#
#
# Bring up the system
# docker-compose up -d
cp ./config-template/docker-compose-local.yml docker-compose.yml
docker-compose up -d
#
read -t 5 -p "Wait 30 second for mySQL Service Ready"
docker exec xlp_mediawiki php /var/www/html/maintenance/update.php --quick
./script/mtm-sql.sh
#
echo "Installation completed"
# display login information
echo "---------------------------------------------------------------------------"
echo "Installation is complete, please read below information"
echo "To access MediaWiki [localhost:$PORT_NUMBER], please use admin/xlp-admin-pass"
echo "To access Matomo [localhost:$MATOMO_PORT_NUMBER], please use user/bitnami"
echo ""
echo "---------------------------------------------------------------------------"

# display finish time
date