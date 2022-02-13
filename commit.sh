#
docker commit -a "Muhammad Haviz" -m "pkc_phpmyadmin" bce23378a910 emhavis/pkc_phpmyadmin:$1
docker push emhavis/pkc_phpmyadmin:$1
#
docker commit -a "Muhammad Haviz" -m "pkc_semanticwiki" effd6798fb17 emhavis/pkc_semanticwiki:$1
docker push emhavis/pkc_semanticwiki:$1
#
docker commit -a "Muhammad Haviz" -m "pkc_matomo" ab03b69daf87 emhavis/pkc_matomo:$1
docker push emhavis/pkc_matomo:$1
#
docker commit -a "Muhammad Haviz" -m "pkc_gitea" fb932103b460 emhavis/pkc_gitea:$1
docker push emhavis/pkc_gitea:$1
#
docker commit -a "Muhammad Haviz" -m "pkc_mariadb" 6ae2a1934c41 emhavis/pkc_mariadb:v0.1
docker push emhavis/pkc_mariadb:v0.1
#
docker commit -a "Muhammad Haviz" -m "pkc_codeserver" 07552a07f2b9 emhavis/pkc_codeserver:v0.1
docker push emhavis/pkc_codeserver:v0.1
#
docker commit -a "Muhammad Haviz" -m "pkc_phpmyadmin" bce23378a910 emhavis/pkc_phpmyadmin:v0.1
docker push emhavis/pkc_phpmyadmin:v0.1