# Welcome to Personal Knowledge Container [PKC]

## Pre-Requisite
Before executing installation, please adjust .env file according to your installation scenarios.
There are three entry at .env that you need to adjust. 
1. YOUR_DOMAIN
Please input as "Localhost" for local installation. This entry will install minimum configuration of PKC consist of MediaWiki, MariaDB, and Matomo inside the docker container for your local installation. At the current version its only supporting MacOS.
To install into your Cloud VMs, please input your domain name into this field. Please also noted that you also have to adjust hosts file to command the installer on how to reach the server.
2. DEFAULT_TRANSPORT
At the moment, only HTTPS protocol is supported for remote installation. SSL certification will be issued using automatically using Certbot
3. YOUR_EMAIL_ADDRESS
Please input your email address for SSL Key Certificate registration on Certbot.

## notes on remote installation
Below are several item that you need to prepare for remote installation.
1. Ensure that you already have register your VM's or remote server Public IP Address into domain registrant, e.g Google Domain, GoDaddy, etc
2. Ensure that the VM can be accessed using private key file, since the installer will be using Ansible script to perform installation. a Clean install of Linux OS at the remote service will be sufficient

## Usage Description
After above items is reviewed and adjust, please change your working folder into installation folder and run ./up.sh
The default credentials to access all the service will be displayed at the end of installation process.

## More Info
Please visit https://www.pkc.pub/index.php/PKC_Complete_Installation_Process for more information.
