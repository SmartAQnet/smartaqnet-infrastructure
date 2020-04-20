#!/bin/bash

VIRTUAL_SWARM_WORKER_ONE_ID=$(docker ps -qf "name=swarm-worker-1")
INNER_POSTGIS_CONTAINER_ID=$(docker exec $VIRTUAL_SWARM_WORKER_ONE_ID docker ps -qf "name=postgis_master")

runInPostgresContainer() {
    #This function executes "docker exec" of the host docker CLI to reach the docker CLI of the first worker to reach the inner Postgres container
    docker exec -i $VIRTUAL_SWARM_WORKER_ONE_ID docker exec -i $INNER_POSTGIS_CONTAINER_ID "$@"
}

runInPostgresContainer psql --username=sensorthings < globals.sql
runInPostgresContainer psql --username=sensorthings < schema.sql
runInPostgresContainer psql --username=sensorthings < basicdata.sql
runInPostgresContainer psql --username=sensorthings < prepare_hypertable.sql
cat sample_features.csv | runInPostgresContainer timescaledb-parallel-copy --connection "host=localhost user=sensorthings sslmode=disable password=ChangeMe" --db-name sensorthings --workers=1 --table FEATURES --copy-options "CSV"
cat sample_observations.csv | runInPostgresContainer timescaledb-parallel-copy --connection "host=localhost user=sensorthings sslmode=disable password=ChangeMe" --db-name sensorthings --workers=1 --table OBSERVATIONS --copy-options "CSV"