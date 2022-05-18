#! /bin/bash
#
# read from config files pkc-mirror.cfg

# check config files
if [ ! -f mirror.config ]; then
    echo "mirror.cfg configuration is not exists, terminating shell script"
    exit 
else
    . mirror.config
fi
#
# generate host configuration file for ansible yml
echo "$source_server_ip ansible_connection=ssh ansible_ssh_private_key_file=$source_server_private_key ansible_user=$source_server_user"

# execute ansible yml file
echo "ansible-playbook -i cs-remote-host ./cs-install-ans.yml"
#

