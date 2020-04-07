#!/bin/bash

export HOST_NAME=api.smartaq.net
export BASIC_AUTH=false
echo "" | docker secret create basic-auth-password -
echo "" | docker secret create basic-auth-user -

docker node update --label-add postgis=master swarm-worker-1

docker service create --name registry --publish published=5000,target=5000 registry:2

docker-compose -f ../postgis/docker-compose.yml -f ./docker-compose.postgis.yml build
docker-compose -f ../postgis/docker-compose.yml -f ./docker-compose.postgis.yml push
docker-compose -f ../netdata/docker-compose.yml -f ./docker-compose.netdata.yml build
docker-compose -f ../netdata/docker-compose.yml -f ./docker-compose.netdata.yml push

docker stack deploy -c ../traefik/docker-compose.yml traefik
docker stack deploy -c ../postgis/docker-compose.yml -c ./docker-compose.postgis.yml postgis
docker stack deploy -c ../frost/docker-compose.yml -c ./docker-compose.frost.yml -c ./docker-compose.frost.master_only.yml frost

#docker stack deploy -c ../faas/docker-compose.yml -c ../faas/docker-compose.traefik.yml faas
docker stack deploy -c ../netdata/docker-compose.yml -c ./docker-compose.netdata.yml netdata
docker stack deploy -c ../portainer/docker-compose.yml portainer