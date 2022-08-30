#! /bin/bash
#
#########################################################################
# Prepare new LocalSettings.php
#
# ./cs-cerbot.sh $1
# $1 ->> host inventory file
#
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
    SWG_SUBDOMAIN=swg.$YOUR_DOMAIN
    QTUX_SUBDOMAIN=qtux.$YOUR_DOMAIN
else
    echo ".env files not found, please provide the .env file"
    exit 1;
fi

echo "Prepare configuration file"
FQDN="https://www.$YOUR_DOMAIN"
KCK_FQDN="https://kck.$YOUR_DOMAIN"
#
sed "s/#MTM_SUBDOMAIN/$MTM_SUBDOMAIN/g" ./config-template/LocalSettings.php > ./config/LocalSettings.php
sed -i "s|#YOUR_FQDN|$FQDN|g" ./config/LocalSettings.php
sed -i "s|#KCK_SUBDOMAIN|$KCK_FQDN|g" ./config/LocalSettings.php
#
sed "s/#YOUR_DOMAIN/$YOUR_DOMAIN/g" ./config-template/default.yml > ./config/default.yml
sed -i "s|#YOUR_EMAIL_ADDRESS|$YOUR_EMAIL_ADDRESS|g" ./config/default.yml
sed -i "s|#DEFAULT_TRANSPORT|$DEFAULT_TRANSPORT|g" ./config/default.yml
#
echo "Running Ansible cerbot script"
ansible-playbook -i ./$1 ./resources/ansible-yml/cs-certbot.yml