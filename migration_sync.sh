REMOTE_SSH=ubuntu@193.196.37.73 #BW-Cloud
IDENTITY_FILE=/home/ubuntu/BW-Cluster.pem
REMOTE_DOCKER_CONTAINER=0aeea84b4c9e #list containers: "docker ps", use a postgres container
LOCAL_DOCKER_CONTAINER=849fe2f4a6ba
IMPORT_WORKERS=8
IMPORT_START_DATE="2020-04-03 16:59:46"
IMPORT_END_DATE="2020-04-05 16:01:00"

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

#Copying unique rows into csv
echo "Copying unique rows into csv"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL >new_features.csv
    COPY (
        select "FEATURES_TMP".* from "FEATURES_TMP"
        LEFT JOIN "FEATURES" ON "FEATURES"."ID" = "FEATURES_TMP"."ID"
        WHERE "FEATURES"."ID" IS NULL)
    TO STDOUT DELIMITER ',' CSV
EOSQL
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL >new_observations.csv
    COPY (
        select "OBSERVATIONS_TMP".* from "OBSERVATIONS_TMP"
        LEFT JOIN "OBSERVATIONS" ON "OBSERVATIONS"."ID" = "OBSERVATIONS_TMP"."ID" AND "OBSERVATIONS"."PHENOMENON_TIME_END" = "OBSERVATIONS_TMP"."PHENOMENON_TIME_END"
        WHERE "OBSERVATIONS"."ID" IS NULL)
    TO STDOUT DELIMITER ',' CSV
EOSQL
#Copying into real tables
echo "Copying into real tables"
cat new_features.csv | pv | docker exec -i $LOCAL_DOCKER_CONTAINER timescaledb-parallel-copy --connection "host=localhost user=sensorthings sslmode=disable password=ChangeMe" --db-name sensorthings --table FEATURES --workers $IMPORT_WORKERS --copy-options "CSV"
cat new_observations.csv | pv | docker exec -i $LOCAL_DOCKER_CONTAINER timescaledb-parallel-copy --connection "host=localhost user=sensorthings sslmode=disable password=ChangeMe" --db-name sensorthings --table OBSERVATIONS --workers 1 --copy-options "CSV"

# #Delete unlogged tables
echo "Delete unlogged tables"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
    DROP TABLE "OBSERVATIONS_TMP";
    DROP TABLE "FEATURES_TMP";
EOSQL