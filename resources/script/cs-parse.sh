#!/bin/bash
rm ./temp-out
touch ./temp-out
sentence=$(cat ./resources/config/hosts)
for word in $sentence
do
    echo $word >> temp-out
done
export $(cat ./temp-out | grep -v '#' | awk '/=/ {print $1}')
echo $host
echo $ansible_connection
echo $ansible_ssh_private_key_file
echo $ansible_user
echo $domain
echo $default_transport
echo $email
# echo $host