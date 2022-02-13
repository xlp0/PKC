#!/bin/bash
docker exec xlp_mariadb /bin/sh -c 'mysql -u root -psecret < /mnt/backup_restore/mariadb/update-mtm-config.sql'