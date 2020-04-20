REMOTE_SSH=ubuntu@193.196.37.73 #BW-Cloud
IDENTITY_FILE=/home/ubuntu/BW-Cluster.pem
REMOTE_DOCKER_CONTAINER=0aeea84b4c9e #list containers: "docker ps", use a postgres container
LOCAL_DOCKER_CONTAINER=e9bd26a40f87
IMPORT_WORKERS=8
IMPORT_END_DATE=2020-03-25

#Export remote global objects and import them locally
echo "Export remote global objects and import them locally"
ssh $REMOTE_SSH -i $IDENTITY_FILE "docker exec -i $REMOTE_DOCKER_CONTAINER pg_dumpall --username sensorthings --globals-only" | docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings

#Export remote database schema and import locally
echo "Export remote database schema and import locally"
ssh $REMOTE_SSH -i $IDENTITY_FILE "docker exec -i $REMOTE_DOCKER_CONTAINER pg_dump -Fc -Z 9 --username sensorthings -s" | docker exec -i $LOCAL_DOCKER_CONTAINER pg_restore --username sensorthings --dbname sensorthings

echo "Copy local Observation table 'OBSERVATIONS' schema into new table 'OBSERVATIONS_NEW' "
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
CREATE TABLE "OBSERVATIONS_NEW" (LIKE "OBSERVATIONS" INCLUDING DEFAULTS EXCLUDING CONSTRAINTS EXCLUDING INDEXES);
EOSQL

echo "Drop local Observation table 'OBSERVATIONS' and rename 'OBSERVATIONS_NEW' to 'OBSERVATIONS'"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
DROP TABLE "OBSERVATIONS";
ALTER TABLE "OBSERVATIONS_NEW" RENAME TO "OBSERVATIONS";
EOSQL

#Import everything except Features and Observations from remote
echo "Import everything except Features and Observations from remote"
ssh $REMOTE_SSH -i $IDENTITY_FILE "docker exec -i $REMOTE_DOCKER_CONTAINER  pg_dump -Fc -Z 9 --data-only --exclude-table \"\\\"OBSERVATIONS\\\"\" --exclude-table \"\\\"FEATURES\\\"\" --username sensorthings" | docker exec -i $LOCAL_DOCKER_CONTAINER pg_restore --username sensorthings --dbname sensorthings

#Create Hypertable
echo "Create Hypertable"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
SELECT * FROM create_hypertable('"OBSERVATIONS"', 'PHENOMENON_TIME_START', chunk_time_interval => interval '14 days');
EOSQL

#Import Features
echo "Import Features"
ssh $REMOTE_SSH -i $IDENTITY_FILE docker exec -i $REMOTE_DOCKER_CONTAINER psql --username sensorthings -c "\"\\COPY (select distinct on (\\\"FEATURES\\\".\\\"ID\\\") \\\"FEATURES\\\".\\\"ID\\\", \\\"FEATURES\\\".\\\"NAME\\\", \\\"FEATURES\\\".\\\"DESCRIPTION\\\", \\\"FEATURES\\\".\\\"ENCODING_TYPE\\\", \\\"FEATURES\\\".\\\"FEATURE\\\", \\\"FEATURES\\\".\\\"GEOM\\\", \\\"FEATURES\\\".\\\"PROPERTIES\\\" from \\\"FEATURES\\\" inner join \\\"OBSERVATIONS\\\" on \\\"FEATURES\\\".\\\"ID\\\"=\\\"OBSERVATIONS\\\".\\\"FEATURE_ID\\\" where \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" < '$IMPORT_END_DATE') TO STDOUT DELIMITER ',' CSV\"" | pv | docker exec -i $LOCAL_DOCKER_CONTAINER timescaledb-parallel-copy --connection "host=localhost user=sensorthings sslmode=disable password=ChangeMe" --db-name sensorthings --table FEATURES --workers $IMPORT_WORKERS --copy-options "CSV"

#Import Observations
echo "Import Observations"
ssh $REMOTE_SSH -i $IDENTITY_FILE docker exec -i $REMOTE_DOCKER_CONTAINER psql --username sensorthings -c "\"\\COPY (SELECT * FROM \\\"OBSERVATIONS\\\" where \\\"OBSERVATIONS\\\".\\\"PHENOMENON_TIME_END\\\" < '$IMPORT_END_DATE') TO STDOUT DELIMITER ',' CSV\"" | pv |docker exec -i $LOCAL_DOCKER_CONTAINER timescaledb-parallel-copy --connection "host=localhost user=sensorthings sslmode=disable password=ChangeMe" --db-name sensorthings --table OBSERVATIONS --workers $IMPORT_WORKERS --copy-options "CSV"

#Create indices on Observation table
echo "Create indices on Observation table"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
   CREATE INDEX "OBSERVATIONS_DATASTREAM_ID_NEW" ON public."OBSERVATIONS" USING btree ("DATASTREAM_ID");
   CREATE INDEX "OBSERVATIONS_FEATURE_ID_NEW" ON public."OBSERVATIONS" USING btree ("FEATURE_ID");
   CREATE INDEX "OBSERVATIONS_PKEY_NEW" ON public."OBSERVATIONS" USING btree ("ID");
   CREATE INDEX observations_filter_datastream_in_time_range_new ON public."OBSERVATIONS" USING btree ("PHENOMENON_TIME_START" DESC, "PHENOMENON_TIME_END" DESC, "DATASTREAM_ID");
   CREATE INDEX observations_phenomenon_time_end_idx_new ON public."OBSERVATIONS" USING btree ("PHENOMENON_TIME_END");
   CREATE INDEX observations_result_time_idx_new ON public."OBSERVATIONS" USING btree ("RESULT_TIME");
EOSQL

#Create foreign keys on Observation table
echo "Create foreign keys on Observation table"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
    ALTER TABLE public."OBSERVATIONS" ADD CONSTRAINT observations_new_fk FOREIGN KEY ("DATASTREAM_ID") REFERENCES "DATASTREAMS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;
    ALTER TABLE public."OBSERVATIONS" ADD CONSTRAINT observations_new_fk2 FOREIGN KEY ("FEATURE_ID") REFERENCES "FEATURES"("ID") ON UPDATE CASCADE ON DELETE CASCADE;
EOSQL

#Create unique id,time constraint on Observation table
echo "Create unique id,time constraint on Observation table"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
   ALTER TABLE public."OBSERVATIONS" ADD CONSTRAINT observations_un UNIQUE ("ID","PHENOMENON_TIME_START");
EOSQL

#Create triggers for 'OBSERVATIONS' table
echo "Create triggers for 'OBSERVATIONS' table"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
   create trigger datastreams_actualization_delete after
   delete
       on
       public."OBSERVATIONS" for each row execute procedure datastreams_update_delete();

   create trigger datastreams_actualization_insert after
   insert
       on
       public."OBSERVATIONS" for each row execute procedure datastreams_update_insert();

   create trigger datastreams_actualization_update after
   update
       on
       public."OBSERVATIONS" for each row execute procedure datastreams_update_update();
EOSQL

#deactivate synchronous_commit
echo "deactivate synchronous_commit"
docker exec -i $LOCAL_DOCKER_CONTAINER psql --username sensorthings <<-EOSQL
   alter system set synchronous_commit= 'off';
EOSQL