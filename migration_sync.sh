REMOTE_SSH=ubuntu@193.196.37.73 #BW-Cloud
IDENTITY_FILE=/home/ubuntu/BW-Cluster.pem
REMOTE_DOCKER_CONTAINER=0aeea84b4c9e #list containers: "docker ps", use a postgres container
LOCAL_DOCKER_CONTAINER=6d0ef5901307822ccedfa3c3b3240209172231f2c28b7f69148de4bc77f0ec85
IMPORT_WORKERS=8
IMPORT_START_DATE=2020-03-25
IMPORT_END_DATE="2020-03-30 09:20:00"

#Create unlogged tables to store rows temporally
echo "Create unlogged tables to store rows temporally"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
    CREATE UNLOGGED TABLE "OBSERVATIONS_TMP" (LIKE "OBSERVATIONS" INCLUDING DEFAULTS EXCLUDING CONSTRAINTS EXCLUDING INDEXES);
    CREATE UNLOGGED TABLE "FEATURES_TMP" (LIKE "FEATURES" INCLUDING DEFAULTS EXCLUDING CONSTRAINTS EXCLUDING INDEXES);
EOSQL

#Import Features
echo "Import Features"
ssh $REMOTE_SSH -i $IDENTITY_FILE docker exec -i $REMOTE_DOCKER_CONTAINER psql --username sensorthings -c "\"\\COPY (select \\\"FEATURES\\\".* from \\\"FEATURES\\\" inner join \\\"OBSERVATIONS\\\" on \\\"FEATURES\\\".\\\"ID\\\"=\\\"OBSERVATIONS\\\".\\\"FEATURE_ID\\\" where \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" < '$IMPORT_END_DATE' AND \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" > '$IMPORT_START_DATE') TO STDOUT DELIMITER ',' CSV\"" | pv | docker exec -i $LOCAL_DOCKER_CONTAINER timescaledb-parallel-copy --connection "host=localhost user=sensorthings sslmode=disable password=ChangeMe" --db-name sensorthings --table FEATURES_TMP --workers $IMPORT_WORKERS --copy-options "CSV"

#Import Observations
echo "Import Observations"
ssh $REMOTE_SSH -i $IDENTITY_FILE docker exec -i $REMOTE_DOCKER_CONTAINER psql --username sensorthings -c "\"\\COPY (SELECT * FROM \\\"OBSERVATIONS\\\" where \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" < '$IMPORT_END_DATE' AND \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" > '$IMPORT_START_DATE') TO STDOUT DELIMITER ',' CSV\"" | pv |docker exec -i $LOCAL_DOCKER_CONTAINER timescaledb-parallel-copy --connection "host=localhost user=sensorthings sslmode=disable password=ChangeMe" --db-name sensorthings --table OBSERVATIONS_TMP --workers $IMPORT_WORKERS --copy-options "CSV"

# #Copying into real tables
# echo "Copying into real tables"
# docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
#     INSERT INTO "OBSERVATIONS"
#     SELECT *
#     FROM "OBSERVATIONS_TMP"
#     ON CONFLICT DO NOTHING;

#     INSERT INTO "FEATURES"
#     SELECT *
#     FROM "FEATURES_TMP"
#     ON CONFLICT DO NOTHING;
# EOSQL

# #Delete unlogged tables
# echo "Copying into real tables"
# docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
#     DROP TABLE "OBSERVATIONS_TMP";
#     DROP TABLE "FEATURES_TMP";
# EOSQL