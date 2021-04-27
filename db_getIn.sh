#! /bin/bash

LOWERCASE_CURRENTDIR="$(tr [A-Z] [a-z] <<< "${PWD##*/}")"

docker exec -i -t $LOWERCASE_CURRENTDIR"_database_1" /bin/bash
