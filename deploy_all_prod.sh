#!/bin/bash

export HOST_NAME=api.smartaq.net

# ------ FAAS Options ---------
export BASIC_AUTH=false
echo "" | docker secret create basic-auth-password -
echo "" | docker secret create basic-auth-user -
# ------ FAAS Options End ---------

docker stack deploy -c ./traefik/docker-compose.yml traefik
#docker stack deploy -c ./registry/docker-compose.yml registry

#sleep 15

docker-compose -f ./postgis/docker-compose.yml build
docker-compose -f ./postgis/docker-compose.yml push
docker-compose -f ./netdata/docker-compose.yml build
docker-compose -f ./netdata/docker-compose.yml push

docker stack deploy --with-registry-auth -c ./postgis/docker-compose.yml postgis
docker stack deploy -c ./frost/docker-compose.yml frost

docker stack deploy -c ./faas/docker-compose.yml -c ./faas/docker-compose.traefik.yml faas
docker stack deploy --with-registry-auth -c ./netdata/docker-compose.yml netdata
docker stack deploy -c ./portainer/docker-compose.yml portainer
docker stack deploy -c ./kafka/kafka.docker-compose.yml -c ./kafka/influx.docker-compose.yml kafka