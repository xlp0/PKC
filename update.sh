

LOWERCASE_CURRENTDIR="$(tr [A-Z] [a-z] <<< "${PWD##*/}")"
MW_CONTAINER=$LOWERCASE_CURRENTDIR"_mediawiki_1"
DB_CONTAINER=$LOWERCASE_CURRENTDIR"_database_1"
docker exec $MW_CONTAINER php /var/www/html/maintenance/update.php