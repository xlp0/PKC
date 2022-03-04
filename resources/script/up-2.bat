REM try to remove all available docker image, start zero
REM docker rmi $(docker images -a -q)
REM Loading all images
docker load -i ./docker-image/xlp_codeserver.tar.gz
docker load -i ./docker-image/xlp_gitea.tar.gz
docker load -i ./docker-image/xlp_mariadb.tar.gz
docker load -i ./docker-image/xlp_matomo.tar.gz
docker load -i ./docker-image/xlp_mediawiki.tar.gz
docker load -i ./docker-image/xlp_phpmyadmin.tar.gz
REM Copy Config File
copy %cd%\config\LocalSettings.php %cd%\mountpoint\LocalSettings.php /Y
copy %cd%\config\config.ini.php %cd%\mountpoint\matomo\config\config.ini.php /Y
REM Bring up the system
docker-compose up -d
echo ""
docker exec -it xlp_mediawiki php ./maintenance/update.php --quick
echo ""
