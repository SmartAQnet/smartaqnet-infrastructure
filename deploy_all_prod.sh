#!/bin/bash

#Export HOST_NAME for use in Traefik and Frost. Frost uses this to determine links (e.g. nextlinks)
#Traefik uses this for routes
export HOST_NAME=api.smartaq.net

# ------ FAAS Options ---------
#Deactivates basic auth in the FAAS gateway. The Gateway is behind Traefik and traefik handles auth.
export BASIC_AUTH=false
echo "" | docker secret create basic-auth-password -
echo "" | docker secret create basic-auth-user -
# ------ FAAS Options End ---------

#Deploy the Traefik TCP & HTTP reverse proxy first
docker stack deploy -c ./traefik/docker-compose.yml traefik

#Build the open source image of timescaleDB postgis. The official image is under the timescale license. This image is built from the Apache 2.0 licensed core and adds the postgis extension.
cd postgis
./deploy_timescaledb-oss.sh
cd ..

#Before executing this file, please follow the instructions in netdata/secrets/README

#Build and push postgis and netdata to the TECO docker registry
docker-compose -f ./postgis/docker-compose.yml build
docker-compose -f ./postgis/docker-compose.yml push


#Create empty secret files for telegram bot
touch ./netdata/secrets/TELEGRAM_BOT_TOKEN
touch ./netdata/secrets/DEFAULT_RECIPIENT_TELEGRAM

docker-compose -f ./netdata/docker-compose.yml -f ./netdata/docker-compose.secrets.yml build
docker-compose -f ./netdata/docker-compose.yml -f ./netdata/docker-compose.secrets.yml push

docker stack rm netdata
docker config create --template-driver golang netdata_health_alarm_notify ./netdata/health_alarm_notify.conf

#Deploys all stacks to the cluster
docker stack deploy --with-registry-auth -c ./postgis/docker-compose.yml postgis
docker stack deploy -c ./frost/docker-compose.yml frost
docker stack deploy -c ./faas/docker-compose.yml -c ./faas/docker-compose.traefik.yml faas
docker stack deploy --with-registry-auth -c ./netdata/docker-compose.yml -c ./netdata/docker-compose.secrets.yml netdata
docker stack deploy -c ./portainer/docker-compose.yml portainer
docker stack deploy -c ./kafka/kafka.docker-compose.yml -c ./kafka/influx.docker-compose.yml kafka