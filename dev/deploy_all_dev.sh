#!/bin/bash

export HOST_NAME=localhost
export BASIC_AUTH=false
echo "" | docker secret create basic-auth-password -
echo "" | docker secret create basic-auth-user -

docker node update --label-add postgis=master swarm-worker-1
docker node update --label-add postgis=replica swarm-worker-2
docker node update --label-add postgis=replica swarm-worker-3

docker service rm registry
docker service create --name registry --publish published=5001,target=5001 --env REGISTRY_HTTP_ADDR=0.0.0.0:5001 registry:2

sleep 15

cd ../postgis
./deploy_timescaledb-oss-dev.sh
cd ../dev

docker-compose -f ../postgis/docker-compose.yml -f ./docker-compose.postgis.yml build
docker-compose -f ../postgis/docker-compose.yml -f ./docker-compose.postgis.yml push
docker-compose -f ../netdata/docker-compose.yml -f ./docker-compose.netdata.yml build
docker-compose -f ../netdata/docker-compose.yml -f ./docker-compose.netdata.yml push

docker stack deploy -c ../traefik/docker-compose.yml traefik
docker stack deploy -c ../postgis/docker-compose.yml -c ./docker-compose.postgis.yml postgis
docker stack deploy -c ../frost/docker-compose.yml -c ./docker-compose.frost.yml frost

docker stack deploy -c ../faas/docker-compose.yml -c ../faas/docker-compose.traefik.yml faas
docker stack deploy -c ../netdata/docker-compose.yml -c ./docker-compose.netdata.yml netdata
docker stack deploy -c ../portainer/docker-compose.yml portainer
docker stack deploy -c ../kafka/kafka.docker-compose.yml -c ../kafka/influx.docker-compose.yml kafka