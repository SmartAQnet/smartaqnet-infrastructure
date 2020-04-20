
--Create Hypertable
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

CREATE TABLE public."OBSERVATIONS" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "PHENOMENON_TIME_START" timestamp with time zone NOT NULL,
    "PHENOMENON_TIME_END" timestamp with time zone,
    "RESULT_TIME" timestamp with time zone,
    "RESULT_TYPE" smallint,
    "RESULT_NUMBER" double precision,
    "RESULT_STRING" text,
    "RESULT_JSON" text,
    "RESULT_BOOLEAN" boolean,
    "RESULT_QUALITY" text,
    "VALID_TIME_START" timestamp with time zone,
    "VALID_TIME_END" timestamp with time zone,
    "PARAMETERS" text,
    "DATASTREAM_ID" character varying,
    "FEATURE_ID" character varying NOT NULL,
    "MULTI_DATASTREAM_ID" character varying
);
SELECT * FROM create_hypertable('"OBSERVATIONS"', 'PHENOMENON_TIME_START', chunk_time_interval => interval '14 days');


ALTER TABLE public."OBSERVATIONS" OWNER TO sensorthings;

--Create indices on Observation table
CREATE INDEX "OBSERVATIONS_DATASTREAM_ID_NEW" ON public."OBSERVATIONS" USING btree ("DATASTREAM_ID");
CREATE INDEX "OBSERVATIONS_FEATURE_ID_NEW" ON public."OBSERVATIONS" USING btree ("FEATURE_ID");
CREATE INDEX "OBSERVATIONS_PKEY_NEW" ON public."OBSERVATIONS" USING btree ("ID");
CREATE INDEX observations_filter_datastream_in_time_range_new ON public."OBSERVATIONS" USING btree ("PHENOMENON_TIME_START" DESC, "PHENOMENON_TIME_END" DESC, "DATASTREAM_ID");
CREATE INDEX observations_phenomenon_time_end_idx_new ON public."OBSERVATIONS" USING btree ("PHENOMENON_TIME_END");
CREATE INDEX observations_result_time_idx_new ON public."OBSERVATIONS" USING btree ("RESULT_TIME");

--Create foreign keys on Observation table
ALTER TABLE public."OBSERVATIONS" ADD CONSTRAINT observations_new_fk FOREIGN KEY ("DATASTREAM_ID") REFERENCES "DATASTREAMS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE public."OBSERVATIONS" ADD CONSTRAINT observations_new_fk2 FOREIGN KEY ("FEATURE_ID") REFERENCES "FEATURES"("ID") ON UPDATE CASCADE ON DELETE CASCADE;

--Create unique id,time constraint on Observation table
ALTER TABLE public."OBSERVATIONS" ADD CONSTRAINT observations_un UNIQUE ("ID","PHENOMENON_TIME_START");

--Create triggers for 'OBSERVATIONS' table
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

--deactivate synchronous_commit
alter system set synchronous_commit= 'off';