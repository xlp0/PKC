#!/bin/bash

#####################################################################
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

#####################################################################
function prep_local {
    # 
    # extracting mountpoint
    # Make sure that the docker-compose.yml is available in this directory, otherwise, download it.
    if [ ! -e ./mountpoint ]; then
        echo "Extracting mountpoint"
        tar -xvf mountpoint.tar.gz > /dev/null 2>&1
    fi
    # copy LocalSettings.php
    echo "Applying Localhost setting .... "
    cp ./config/LocalSettings.php ./mountpoint/LocalSettings.php
    # cp ./config/config.ini.php-local ./mountpoint/matomo/config/config.ini.php
    # cp ./config-template/LocalSettings-local.php ./mountpoint/LocalSettings.php
    # config/app.ini
    cp ./config/app.ini ./mountpoint/gitea/gitea/conf/app.ini
    cp ./config/update-mtm-config.sql ./mountpoint/backup_restore/mariadb/update-mtm-config.sql
    # docker composre file, consist of minimal installation
    cp ./config-template/docker-compose-local.yml docker-compose.yml

}

function prep_mw_localhost {
    echo "Prepare LocalSettings.php file"
    FQDN="$DEFAULT_TRANSPORT://$YOUR_DOMAIN:$PORT_NUMBER"
    # KCK_AUTH_FQDN="$DEFAULT_TRANSPORT://$YOUR_DOMAIN:$KCK_PORT_NUMBER"
    KCK_AUTH_FQDN="https://kck.pkc-ops.org"
    MTM_FQDN="$DEFAULT_TRANSPORT://$YOUR_DOMAIN:$MATOMO_PORT_NUMBER"
    GIT_FQDN="$DEFAULT_TRANSPORT://$YOUR_DOMAIN:$GITEA_PORT_NUMBER"
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

function prep_mw_domain {
    echo "Prepare LocalSettings.php file"
    FQDN="$DEFAULT_TRANSPORT://www.$YOUR_DOMAIN"
    KCK_AUTH_FQDN="$DEFAULT_TRANSPORT://kck.$YOUR_DOMAIN"
    MTM_FQDN="$DEFAULT_TRANSPORT://mtm.$YOUR_DOMAIN"
    MTM_ROOT="mtm.$YOUR_DOMAIN"
    GIT_FQDN="$DEFAULT_TRANSPORT://git.$YOUR_DOMAIN"
    #
    sed "s|#MTM_SUBDOMAIN|$MTM_ROOT|g" ./config-template/LocalSettings.php > ./config/LocalSettings.php
    sed -i '' "s|#YOUR_FQDN|$FQDN|g" ./config/LocalSettings.php
    sed -i '' "s|#KCK_SUBDOMAIN|$KCK_AUTH_FQDN|g" ./config/LocalSettings.php
    #
    sed "s|#MTM_SUBDOMAIN|$MTM_FQDN|g" ./config-template/config.ini.php > ./config/config.ini.php
    #
    sed "s|#YOUR_DOMAIN|$YOUR_DOMAIN|g" ./config-template/update-mtm-config.sql > ./config/update-mtm-config.sql
    sed -i '' "s|#YOUR_KCK_FQDN_DOMAIN|$KCK_AUTH_FQDN|g" ./config/update-mtm-config.sql
    #
    sed "s|#GIT_FQDN|$GIT_FQDN|g" ./config-template/app.ini > ./config/app.ini
}

#####################################################################
# Read .env, and present our plan to user
echo "Mark Started Process at $(date)"

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
    if [ "$YOUR_DOMAIN" == "localhost" ]; then {
        GITEA_SUBDOMAIN=$YOUR_DOMAIN:$GITEA_PORT_NUMBER
        PMA_SUBDOMAIN=$YOUR_DOMAIN:$PHP_MA
        MTM_SUBDOMAIN=$YOUR_DOMAIN:$MATOMO_PORT_NUMBER
        VS_SUBDOMAIN=$YOUR_DOMAIN:$VS_PORT_NUMBER
        KCK_SUBDOMAIN=$YOUR_DOMAIN:$KCK_PORT_NUMBER

        # Displays localhost installation plan
        echo "--------------------------------------------------------"
        echo "Installation Plan:"
        echo ""
        echo "Loaded environmental variable: "
        echo "Port number for Mediawiki: $PORT_NUMBER"
        echo "Port number for PHPMyAdmin: $PHP_MA"
        echo ""
        echo "If you have installed Dockers, please ensure your"
        echo "Docker desktop is running."
        echo ""
        read -p "Press [Enter] key to continue..."
        echo "--------------------------------------------------------"

        prep_mw_localhost
        read -p "finished prepare Configuration for Localhost config Press [Enter] key to continue..."
        prep_local
        read -p "finished prepare mountpoint for Localhost Press [Enter] key to continue..."

        # run ansible playbook
        ansible-playbook cs-up-local.yml --connection=local

        # run maintenance script
        echo "Running maintenance script"
        docker exec xlp_mediawiki php /var/www/html/maintenance/update.php --quick > /dev/null 2>&1

        # display login information
        echo "---------------------------------------------------------------------------"
        echo "Installation is complete, please read below information"
        echo "To access MediaWiki [localhost:$PORT_NUMBER], please use admin/xlp-admin-pass"
        echo ""
        echo "If the browser is not automatically open, please copy-paste below URL into "
        echo "your browser "
        echo "http://localhost:32001"
        echo "---------------------------------------------------------------------------"
        open http://localhost:32001

    } else {
        GITEA_SUBDOMAIN=git.$YOUR_DOMAIN
        PMA_SUBDOMAIN=pma.$YOUR_DOMAIN
        MTM_SUBDOMAIN=mtm.$YOUR_DOMAIN
        VS_SUBDOMAIN=code.$YOUR_DOMAIN
        KCK_SUBDOMAIN=kck.$YOUR_DOMAIN

        # Displays installation plan on remote host machine
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

        prep_nginx
        read -p "finished prepare nginx config Press [Enter] key to continue..."
        prep_mw_domain
        read -p "finished prepare LocalSettings.php Press [Enter] key to continue..."
        ansible-playbook -i hosts cs-clean.yml
        ansible-playbook -i hosts cs-up.yml
        #
        # Install HTTPS SSL
        if [ $DEFAULT_TRANSPORT == "https" ]; then
            echo "Installing SSL Certbot for $DEFAULT_TRANSPORT protocol"
            ./cs-certbot.sh hosts
        fi
        #
        echo "Check installation status"
        ansible-playbook -i hosts cs-svc.yml  
      
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
    }
    fi
else
    echo ".env files not found, please provide the .env file"
    exit 1;
fi

echo "Mark Finished Process at $(date)"