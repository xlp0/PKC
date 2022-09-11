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
    # sed -i "s|#YOUR_DOMAIN|$YOUR_DOMAIN|g" ./config/kck.conf

    sed "s/#QTUX_SUBDOMAIN/$QTUX_SUBDOMAIN/g" ./config-template/qtux.conf > ./config/qtux.conf
    sed "s/#SWG_SUBDOMAIN/$SWG_SUBDOMAIN/g" ./config-template/swg.conf > ./config/swg.conf

    sed "s/#YOUR_DOMAIN/$YOUR_DOMAIN/g" ./config-template/reverse-proxy.conf > ./config/reverse-proxy.conf
    sed "s/#YOUR_DOMAIN/$YOUR_DOMAIN/g" ./config-template/pkc.conf > ./config/pkc.conf
    # sed -i "s|#KCK_SUBDOMAIN|$KCK_SUBDOMAIN|g" ./config/pkc.conf

    sed "s/#MDL_SUBDOMAIN/$MDL_SUBDOMAIN/g" ./config-template/mdl.conf > ./config/mdl.conf
    echo ""
}

#####################################################################
function prep_local {

    # check if we already have mountpoint file
    if [ ! -f ./mountpoint.tar.gz ]; then
        # download mountpoint from pkc.pub
        echo "Download mountpoint"
        wget -O mountpoint.tar.gz http://res.pkc.pub/mountpoint-mac.tar.gz
    fi     

    # check if folder is already exists
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
    # cp ./config/update-mtm-config.sql ./mountpoint/backup_restore/mariadb/update-mtm-config.sql
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
    # sed "s|#YOUR_KCK_FQDN|$KCK_AUTH_FQDN|g" ./config-template/update-mtm-config.sql > ./config/update-mtm-config.sql
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
    sed -i "s|#YOUR_FQDN|$FQDN|g" ./config/LocalSettings.php
    sed -i "s|#KCK_SUBDOMAIN|$KCK_AUTH_FQDN|g" ./config/LocalSettings.php
    #
    sed "s|#MTM_SUBDOMAIN|$MTM_FQDN|g" ./config-template/config.ini.php > ./config/config.ini.php
    #
    sed "s|#YOUR_DOMAIN|$YOUR_DOMAIN|g" ./config-template/update-mtm-config.sql > ./config/update-mtm-config.sql
    sed -i "s|#YOUR_KCK_FQDN_DOMAIN|$KCK_AUTH_FQDN|g" ./config/update-mtm-config.sql
    #
    sed "s|#GIT_FQDN|$GIT_FQDN|g" ./config-template/app.ini > ./config/app.ini
}

#####################################################################

function prep_vars {
    echo "Reading values from hosts file into variable"

    rm ./temp-out
    touch ./temp-out
    sentence=$(cat ./resources/config/hosts)
    for word in $sentence
    do
        echo $word >> temp-out
    done
    export $(cat ./temp-out | grep -v '#' | awk '/=/ {print $1}')
    ansible_host_name=$(head -n 1 ./temp-out)
    echo $ansible_host_name
    echo $ansible_connection
    echo $ansible_ssh_private_key_file
    echo $ansible_user
    echo $domain
    echo $default_transport
    echo $email
}

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
        MDL_SUBDOMAIN=$YOUR_DOMAIN:$MDL_PORT_NUMBER

        # Displays localhost installation plan
        echo "--------------------------------------------------------"
        echo "Installation Plan:"
        echo ""
        echo "Loaded environmental variable: "
        echo "Port number for Mediawiki: $PORT_NUMBER"
        echo "Port number for PHPMyAdmin: $PHP_MA"
        echo "Port number for Keycloak: $KCK_PORT_NUMBER    "
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
        echo "Running localhost ansible playbook, please provide password when ask."
        ansible-playbook ./resources/ansible-yml/cs-up-local.yml --connection=local --ask-become-pass
        # 
        echo "Wait 10 second for service to ready"
        sleep 5 

        # run maintenance script
        echo "Running maintenance script"
        docker exec xlp_mediawiki php /var/www/html/maintenance/update.php --quick # > /dev/null 2>&1
        # ansible-playbook ./resources/ansible-yml/cs-test.yml --connection=local

        # display login information
        echo "---------------------------------------------------------------------------"
        echo "Installation is complete, please read below information"
        echo "To access MediaWiki [localhost:$PORT_NUMBER], please use admin/xlp-admin-pass"
        echo ""
        echo "If the browser is not automatically open, please copy-paste below URL into "
        echo "your browser "
        echo "http://pkc.local"
        echo "---------------------------------------------------------------------------"
        open http://pkc.local

    } else {

        # Prepare .env file
        echo "Preparing env file"
        ansible-playbook -i ./resources/config/hosts ./resources/ansible-yml/cs-prep-env.yml

        # read the .env file
        export $(cat .env | grep -v '#' | awk '/=/ {print $1}')

        GITEA_SUBDOMAIN=git.$YOUR_DOMAIN
        PMA_SUBDOMAIN=pma.$YOUR_DOMAIN
        MTM_SUBDOMAIN=mtm.$YOUR_DOMAIN
        VS_SUBDOMAIN=code.$YOUR_DOMAIN
        KCK_SUBDOMAIN=kck.$YOUR_DOMAIN
        MDL_SUBDOMAIN=mdl.$YOUR_DOMAIN
        # swagger
        SWG_SUBDOMAIN=swg.$YOUR_DOMAIN
        # quant-ux
        QTUX_SUBDOMAIN=qtux.$YOUR_DOMAIN

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
        echo "Swagger will be accessible from: $SWG_SUBDOMAIN"
        echo "Quant UX will be accessible from: $QTUX_SUBDOMAIN"
        echo ""
        echo ""
        read -p "Press [Enter] key to continue..."
        echo "--------------------------------------------------------"

        prep_vars
        # echo $CMD_VARS
        # read  -p "press enter to continue ..."

        prep_nginx
        read -p "prepare nginx config Press [Enter] key to continue..."
        echo "finished prepare nginx config"
        prep_mw_domain
        echo "finished prepare LocalSettings.php"
        ansible-playbook -i ./resources/config/hosts ./resources/ansible-yml/cs-clean.yml
        ansible-playbook -i ./resources/config/hosts ./resources/ansible-yml/cs-up.yml
        #
        # remote shell, ansible is not stable to bring container services up
        CMD_VARS="ssh -i $ansible_ssh_private_key_file $ansible_user@$ansible_host_name 'cd /home/$ansible_user/cs; docker-compose pull'"
        echo "docker-compose pull"
        eval $CMD_VARS >/dev/null

        CMD_VARS="ssh -i $ansible_ssh_private_key_file $ansible_user@$ansible_host_name 'cd /home/$ansible_user/cs; docker-compose up -d'"
        echo "docker-compose up -d"
        eval $CMD_VARS > /dev/null
        #
        #
        # Install HTTPS SSL
        if [ $DEFAULT_TRANSPORT == "https" ]; then
            echo "Installing SSL Certbot for $DEFAULT_TRANSPORT protocol"
            ./resources/script/cs-certbot.sh ./resources/config/hosts
        fi
        ansible-playbook -i ./resources/config/hosts ./resources/ansible-yml/cs-up-3.yml

        echo "Check installation status"
        ansible-playbook -i ./resources/config/hosts ./resources/ansible-yml/cs-svc.yml  
      
        echo "---------------------------------------------------------------------------"
        echo "Installation is complete, please read below information"
        echo "To access MediaWiki, please use admin/xlp-admin-pass"
        echo "To access Gitea, please use admin/pkc-admin"
        echo "To access Matomo, please use user/bitnami"
        echo "To access phpMyAdmin, please use Database: database, User: pkcmysqladmin, password: P2v*]57[(9mv3BqX"
        echo "To access Code Server, please use password: $VS_PASSWORD"
        echo "To access Keycloak, please use admin/Pa55w0rd"
        echo "To access Quant-UX, please register"
        echo "To access Swagger-API, no password"
        echo ""
        echo "---------------------------------------------------------------------------"

        # display finish time
        date
    }
    fi
else {
    echo ".env files not found, please provide the .env file"
    exit 1;
}
fi

echo "Mark Finished Process at $(date)"