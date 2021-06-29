BACKUPANDRESTORE_DIR=/var/www/html/extensions/BackupAndRestore

init:
	./up.sh

shutdown: backupNow
	docker-compose down --volumes 

removeAllImages: backupNow
	docker rmi -f $(shell docker images -q)

backupNow:
	docker exec -i -t pkc_mediawiki_1 $(BACKUPANDRESTORE_DIR)/backupRegularly.sh
