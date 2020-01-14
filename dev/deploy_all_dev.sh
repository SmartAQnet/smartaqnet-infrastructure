#!/bin/bash

export HOST_NAME=localhost
export BASIC_AUTH=false
echo "" | docker secret create basic-auth-password -
echo "" | docker secret create basic-auth-user -

docker node update --label-add postgis=master swarm-worker-1
docker node update --label-add postgis=replica swarm-worker-2
docker node update --label-add postgis=replica swarm-worker-3

docker service create --name registry --publish published=5000,target=5000 registry:2

docker-compose -f ../postgis/docker-compose.yml -f ./docker-compose.postgis.yml build
docker-compose -f ../postgis/docker-compose.yml -f ./docker-compose.postgis.yml push

docker stack deploy -c ../traefik/docker-compose.yml traefik
docker stack deploy -c ../postgis/docker-compose.yml -c ./docker-compose.postgis.yml postgis
docker stack deploy -c ../frost/docker-compose.yml -c ./docker-compose.frost.yml frost

docker stack deploy -c ../faas/docker-compose.yml -c ../faas/docker-compose.traefik.yml faas