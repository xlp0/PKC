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
    sed "s/#KCK_SUBDOMAIN/$KCK_SUBDOMAIN/g" ./config-template/kck.conf > ./config/kck.conf
    sed "s/#YOUR_DOMAIN/$YOUR_DOMAIN/g" ./config-template/reverse-proxy.conf > ./config/reverse-proxy.conf
    sed "s/#YOUR_DOMAIN/$YOUR_DOMAIN/g" ./config-template/pkc.conf > ./config/pkc.conf
    echo ""
}

function prep_mw {
    echo "Prepare LocalSettings.php file"
    FQDN="$DEFAULT_TRANSPORT://www.$YOUR_DOMAIN"
    KCK_AUTH_FQDN="$DEFAULT_TRANSPORT://kck.$YOUR_DOMAIN"
    MTM_FQDN="$DEFAULT_TRANSPORT://mtm.$YOUR_DOMAIN"
    GIT_FQDN="$DEFAULT_TRANSPORT://git.$YOUR_DOMAIN"
    #
    sed "s/#MTM_SUBDOMAIN/$MTM_SUBDOMAIN/g" ./config-template/LocalSettings.php > ./config/LocalSettings.php
    sed -i '' "s|#YOUR_FQDN|$FQDN|g" ./config/LocalSettings.php
    sed -i '' "s|#KCK_SUBDOMAIN|$KCK_AUTH_FQDN|g" ./config/LocalSettings.php
    #
    sed "s|#MTM_SUBDOMAIN|$MTM_FQDN|g" ./config-template/config.ini.php > ./config/config.ini.php
    #
    sed "s|#YOUR_DOMAIN|$YOUR_DOMAIN|g" ./config-template/update-mtm-config.sql > ./config/update-mtm-config.sql
    #
    sed "s|#GIT_FQDN|$GIT_FQDN|g" ./config-template/app.ini > ./config/app.ini
}
################################################################################
## Main
# Preparation
# 

## Default, if no parameter is supplied
if [ -z "$1" ]; then
    echo "Hosts file is not specified, please see usage below"
    usage; exit 1;
fi

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
    GITEA_SUBDOMAIN=git.$YOUR_DOMAIN
    PMA_SUBDOMAIN=pma.$YOUR_DOMAIN
    MTM_SUBDOMAIN=mtm.$YOUR_DOMAIN
    VS_SUBDOMAIN=code.$YOUR_DOMAIN
    KCK_SUBDOMAIN=kck.$YOUR_DOMAIN

    # Displays installation plan
    echo "--------------------------------------------------------"
    echo "Installation Plan:"
    echo "Ansible script to install on host file: $1"
    echo ""
    echo "Loaded environmental variable: "
    echo "Port number for Mediawiki: $PORT_NUMBER"
    echo "Port number for Matomo Service: $MATOMO_PORT_NUMBER"
    echo "Port number for PHPMyAdmin: $PHP_MA"
    echo "Port number for Gitea Service: $GITEA_PORT_NUMBER"
    echo "Port number for Code Server: $VS_PORT_NUMBER"
    echo "Port number for Keycloak: $KCK_PORT_NUMBER"
    echo ""
    echo "Your domain name is: $YOUR_DOMAIN"
    echo "default installation will configure below subdomain: "
    echo "PHPMyAdmin will be accessible from: $PMA_SUBDOMAIN"
    echo "Gitea will be accessible from: $GITEA_SUBDOMAIN"
    echo "Matomo will be accessible from: $MTM_SUBDOMAIN"
    echo "Code Server will be accessible from: $VS_SUBDOMAIN"
    echo "Keycloak will be accessible from: $KCK_SUBDOMAIN"
    echo ""
    echo ""
    read -p "Press [Enter] key to continue..."
    echo "--------------------------------------------------------"
else
    echo ".env files not found, please provide the .env file"
    exit 1;
fi
# Display execution time
date
# prepares config file
# 1. NGINX Config Files
read -p "Prep nginx Press [Enter] key to continue..."
prep_nginx
# 2. LocalSettings.php files
read -p "Prep mw Press [Enter] key to continue..."
prep_mw
# executing Ansible Playbook
ansible-playbook -i $1 cs-clean.yml
ansible-playbook -i $1 cs-up.yml

if [ $DEFAULT_TRANSPORT == "https" ]; then
    echo "Installing SSL Certbot for $DEFAULT_TRANSPORT protocol"
    ./cs-certbot.sh $1
fi

## check installation status
echo "Check installation status"
ansible-playbook -i $1 cs-svc.yml

echo "Installation completed"
# display login information
echo "---------------------------------------------------------------------------"
echo "Installation is complete, please read below information"
echo "To access MediaWiki, please use admin/xlp-admin-pass"
echo "To access Gitea, please use admin/pkc-admin"
echo "To access Matomo, please use user/bitnami"
echo "To access phpMyAdmin, please use Database: database, User: root, password: secret"
echo "To access Code Server, please use password: $VS_PASSWORD"
echo "To access Keycloak, please use admin/Pa55w0rd"
echo ""
echo "---------------------------------------------------------------------------"

# display finish time
date