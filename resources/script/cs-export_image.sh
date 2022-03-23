#!/bin/bash
docker save emhavis/pkc_mariadb:v0.1 | gzip > pkc_mariadb.tar.gz
docker save emhavis/pkc_gitea:v0.1 | gzip > pkc_gitea.tar.gz
docker save emhavis/pkc_semanticwiki:v1.37.1.build.3 | gzip > pkc_semanticwiki.tar.gz
docker save bitnami/matomo:4 | gzip > pkc_matomo.tar.gz
docker save quay.io/keycloak/keycloak:15.0.2 | gzip > pkc_keycloak.tar.gz
docker save emhavis/pkc_phpmyadmin:v0.1  | gzip > pkc_phpmyadmin.tar.gz
docker save bitnami/moodle:latest | gzip > pkc_moodle.tar.gz
docker save emhavis/pkc_codeserver:v0.1 | gzip > pkc_codeserver.tar.gz
docker save emhavis/pkc_mariadb:v0.1 | gzip > pkc_mariadb.tar.gz