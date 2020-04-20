#!/bin/bash

REMOTE_SSH=ubuntu@smartaqnet-worker1.vm.teco.edu #TECO-Cluster
IDENTITY_FILE=/home/leon/.ssh/id_rsa
REMOTE_DOCKER_CONTAINER=849fe2f4a6ba43837352396b2c82fecb0dd39500fa42be14cbfa6c8d4c3b78d9 #list containers: "docker ps", use a postgres container
#IMPORT_WORKERS=8
#IMPORT_END_DATE=2020-03-25

#Export remote global objects and import them locally
echo "Export remote global objects"
ssh $REMOTE_SSH -i $IDENTITY_FILE "docker exec -i $REMOTE_DOCKER_CONTAINER pg_dumpall --username sensorthings --globals-only" > globals.sql

#Export remote database schema and import locally
echo "Export remote database schema"
ssh $REMOTE_SSH -i $IDENTITY_FILE "docker exec -i $REMOTE_DOCKER_CONTAINER pg_dump --username sensorthings -s  -T 'public.\"OBSERVATIONS\"' --exclude-schema \"_timescaledb*\" -T 'public.*\"_TMP\"'"  > schema.sql

IMPORT_START_DATE="2020-04-13 00:00:00"
IMPORT_END_DATE="2020-04-14 00:00:00"

#Export everything but features and observations
ssh $REMOTE_SSH -i $IDENTITY_FILE "docker exec -i $REMOTE_DOCKER_CONTAINER  pg_dump --data-only -T 'public.\"FEATURES\"' -T 'public.\"OBSERVATIONS\"' --exclude-schema \"_timescaledb*\" -T 'public.*\"_TMP\"' --username sensorthings" > basicdata.sql

#Export Features
echo "Export Features"
ssh $REMOTE_SSH -i $IDENTITY_FILE docker exec -i $REMOTE_DOCKER_CONTAINER psql --username sensorthings -c "\"\\COPY (select \\\"FEATURES\\\".* from \\\"FEATURES\\\" inner join \\\"OBSERVATIONS\\\" on \\\"FEATURES\\\".\\\"ID\\\"=\\\"OBSERVATIONS\\\".\\\"FEATURE_ID\\\" where \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" < '$IMPORT_END_DATE' AND \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" > '$IMPORT_START_DATE') TO STDOUT DELIMITER ',' CSV\"" | pv > sample_features_tmp.csv
cat sample_features_tmp.csv | sort | uniq --check-chars=36  > sample_features.csv
rm sample_features_tmp.csv

#Export Observations
echo "Export Observations"
ssh $REMOTE_SSH -i $IDENTITY_FILE docker exec -i $REMOTE_DOCKER_CONTAINER psql --username sensorthings -c "\"\\COPY (SELECT * FROM \\\"OBSERVATIONS\\\" where \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" < '$IMPORT_END_DATE' AND \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" > '$IMPORT_START_DATE') TO STDOUT DELIMITER ',' CSV\"" | pv > sample_observations.csv