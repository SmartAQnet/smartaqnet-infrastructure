--
-- PostgreSQL database dump
--

-- Dumped from database version 11.7
-- Dumped by pg_dump version 11.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data';


--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: sensorthings
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO sensorthings;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: sensorthings
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO sensorthings;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: sensorthings
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO sensorthings;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: sensorthings
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: datastreams_update_delete(); Type: FUNCTION; Schema: public; Owner: sensorthings
--

CREATE FUNCTION public.datastreams_update_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
"DS_ROW" "DATASTREAMS"%rowtype;
begin

for "DS_ROW" in select * from "DATASTREAMS" where "ID"=OLD."DATASTREAM_ID"
loop
    if (OLD."PHENOMENON_TIME_START" = "DS_ROW"."PHENOMENON_TIME_START"
        or coalesce(OLD."PHENOMENON_TIME_END", OLD."PHENOMENON_TIME_START") = "DS_ROW"."PHENOMENON_TIME_END")
    then
        update "DATASTREAMS"
            set "PHENOMENON_TIME_START" = (select min("PHENOMENON_TIME_START") from "OBSERVATIONS" where "OBSERVATIONS"."DATASTREAM_ID" = "DS_ROW"."ID")
            where "DATASTREAMS"."ID" = "DS_ROW"."ID";
        update "DATASTREAMS"
            set "PHENOMENON_TIME_END" = (select max(coalesce("PHENOMENON_TIME_END", "PHENOMENON_TIME_START")) from "OBSERVATIONS" where "OBSERVATIONS"."DATASTREAM_ID" = "DS_ROW"."ID")
            where "DATASTREAMS"."ID" = "DS_ROW"."ID";
    end if;

    if (OLD."RESULT_TIME" = "DS_ROW"."RESULT_TIME_START")
    then
        update "DATASTREAMS"
            set "RESULT_TIME_START" = (select min("RESULT_TIME") from "OBSERVATIONS" where "OBSERVATIONS"."DATASTREAM_ID" = "DS_ROW"."ID")
            where "DATASTREAMS"."ID" = "DS_ROW"."ID";
    end if;
    if (OLD."RESULT_TIME" = "DS_ROW"."RESULT_TIME_END")
    then
        update "DATASTREAMS"
            set "RESULT_TIME_END" = (select max("RESULT_TIME") from "OBSERVATIONS" where "OBSERVATIONS"."DATASTREAM_ID" = "DS_ROW"."ID")
            where "DATASTREAMS"."ID" = "DS_ROW"."ID";
    end if;
end loop;
return NULL;
end
$$;


ALTER FUNCTION public.datastreams_update_delete() OWNER TO sensorthings;

--
-- Name: datastreams_update_insert(); Type: FUNCTION; Schema: public; Owner: sensorthings
--

CREATE FUNCTION public.datastreams_update_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
"DS_ROW" "DATASTREAMS"%rowtype;
begin

select * into "DS_ROW" from "DATASTREAMS" where "DATASTREAMS"."ID"=NEW."DATASTREAM_ID";
if (NEW."PHENOMENON_TIME_START"<"DS_ROW"."PHENOMENON_TIME_START" or "DS_ROW"."PHENOMENON_TIME_START" is null) then
    update "DATASTREAMS" set "PHENOMENON_TIME_START" = NEW."PHENOMENON_TIME_START" where "DATASTREAMS"."ID" = "DS_ROW"."ID";
end if;
if (coalesce(NEW."PHENOMENON_TIME_END", NEW."PHENOMENON_TIME_START") > "DS_ROW"."PHENOMENON_TIME_END" or "DS_ROW"."PHENOMENON_TIME_END" is null) then
    update "DATASTREAMS" set "PHENOMENON_TIME_END" = coalesce(NEW."PHENOMENON_TIME_END", NEW."PHENOMENON_TIME_START") where "DATASTREAMS"."ID" = "DS_ROW"."ID";
end if;

if (NEW."RESULT_TIME"<"DS_ROW"."RESULT_TIME_START" or "DS_ROW"."RESULT_TIME_START" is null) then
    update "DATASTREAMS" set "RESULT_TIME_START" = NEW."RESULT_TIME" where "DATASTREAMS"."ID" = "DS_ROW"."ID";
end if;
if (NEW."RESULT_TIME" > "DS_ROW"."RESULT_TIME_END" or "DS_ROW"."RESULT_TIME_END" is null) then
    update "DATASTREAMS" set "RESULT_TIME_END" = NEW."RESULT_TIME" where "DATASTREAMS"."ID" = "DS_ROW"."ID";
end if;

update "DATASTREAMS" SET "OBSERVED_AREA" = ST_ConvexHull(ST_Collect("OBSERVED_AREA", (select "GEOM" from "FEATURES" where "ID"=NEW."FEATURE_ID"))) where "DATASTREAMS"."ID"=NEW."DATASTREAM_ID";

return new;
END
$$;


ALTER FUNCTION public.datastreams_update_insert() OWNER TO sensorthings;

--
-- Name: datastreams_update_update(); Type: FUNCTION; Schema: public; Owner: sensorthings
--

CREATE FUNCTION public.datastreams_update_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
"DS_ROW" "DATASTREAMS"%rowtype;
begin

if (NEW."PHENOMENON_TIME_START" != OLD."PHENOMENON_TIME_START" or NEW."PHENOMENON_TIME_END" != OLD."PHENOMENON_TIME_END") then
    for "DS_ROW" in select * from "DATASTREAMS" where "ID"=NEW."DATASTREAM_ID"
    loop
        if (NEW."PHENOMENON_TIME_START"<"DS_ROW"."PHENOMENON_TIME_START") then
            update "DATASTREAMS" set "PHENOMENON_TIME_START" = NEW."PHENOMENON_TIME_START" where "DATASTREAMS"."ID" = "DS_ROW"."ID";
        end if;
        if (coalesce(NEW."PHENOMENON_TIME_END", NEW."PHENOMENON_TIME_START") > "DS_ROW"."PHENOMENON_TIME_END") then
            update "DATASTREAMS" set "PHENOMENON_TIME_END" = coalesce(NEW."PHENOMENON_TIME_END", NEW."PHENOMENON_TIME_START") where "DATASTREAMS"."ID" = "DS_ROW"."ID";
        end if;

        if (OLD."PHENOMENON_TIME_START" = "DS_ROW"."PHENOMENON_TIME_START"
            or coalesce(OLD."PHENOMENON_TIME_END", OLD."PHENOMENON_TIME_START") = "DS_ROW"."PHENOMENON_TIME_END")
        then
            update "DATASTREAMS"
                set "PHENOMENON_TIME_START" = (select min("PHENOMENON_TIME_START") from "OBSERVATIONS" where "OBSERVATIONS"."DATASTREAM_ID" = "DS_ROW"."ID")
                where "DATASTREAMS"."ID" = "DS_ROW"."ID";
            update "DATASTREAMS"
                set "PHENOMENON_TIME_END" = (select max(coalesce("PHENOMENON_TIME_END", "PHENOMENON_TIME_START")) from "OBSERVATIONS" where "OBSERVATIONS"."DATASTREAM_ID" = "DS_ROW"."ID")
                where "DATASTREAMS"."ID" = "DS_ROW"."ID";
        end if;
    end loop;
    return NEW;
end if;

if (NEW."RESULT_TIME" != OLD."RESULT_TIME") then
    for "DS_ROW" in select * from "DATASTREAMS" where "ID"=NEW."DATASTREAM_ID"
    loop
        if (NEW."RESULT_TIME" < "DS_ROW"."RESULT_TIME_START") then
            update "DATASTREAMS" set "RESULT_TIME_START" = NEW."RESULT_TIME" where "ID" = "DS_ROW"."ID";
        end if;
        if (NEW."RESULT_TIME" > "DS_ROW"."RESULT_TIME_END") then
            update "DATASTREAMS" set "RESULT_TIME_END" = NEW."RESULT_TIME" where "ID" = "DS_ROW"."ID";
        end if;

        if (OLD."RESULT_TIME" = "DS_ROW"."RESULT_TIME_START")
        then
            update "DATASTREAMS"
                set "RESULT_TIME_START" = (select min("RESULT_TIME") from "OBSERVATIONS" where "OBSERVATIONS"."DATASTREAM_ID" = "DS_ROW"."ID")
                where "DATASTREAMS"."ID" = "DS_ROW"."ID";
        end if;
        if (OLD."RESULT_TIME" = "DS_ROW"."RESULT_TIME_END")
        then
            update "DATASTREAMS"
                set "RESULT_TIME_END" = (select max("RESULT_TIME") from "OBSERVATIONS" where "OBSERVATIONS"."DATASTREAM_ID" = "DS_ROW"."ID")
                where "DATASTREAMS"."ID" = "DS_ROW"."ID";
        end if;
    end loop;
    return NEW;
end if;


return new;
END
$$;


ALTER FUNCTION public.datastreams_update_update() OWNER TO sensorthings;

--
-- Name: safe_cast_to_boolean(jsonb); Type: FUNCTION; Schema: public; Owner: sensorthings
--

CREATE FUNCTION public.safe_cast_to_boolean(v_input jsonb) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE v_bool_value BOOLEAN DEFAULT NULL;
BEGIN
    IF jsonb_typeof(v_input) = 'boolean' THEN
        RETURN (v_input#>>'{}')::boolean;
    ELSE
        RETURN NULL;
    END IF;
END;
$$;


ALTER FUNCTION public.safe_cast_to_boolean(v_input jsonb) OWNER TO sensorthings;

--
-- Name: safe_cast_to_numeric(jsonb); Type: FUNCTION; Schema: public; Owner: sensorthings
--

CREATE FUNCTION public.safe_cast_to_numeric(v_input jsonb) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE v_num_value NUMERIC DEFAULT NULL;
BEGIN
    IF jsonb_typeof(v_input) = 'number' THEN
        RETURN (v_input#>>'{}')::numeric;
    ELSE
        RETURN NULL;
    END IF;
END;
$$;


ALTER FUNCTION public.safe_cast_to_numeric(v_input jsonb) OWNER TO sensorthings;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ACTUATORS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."ACTUATORS" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "NAME" text,
    "DESCRIPTION" text,
    "PROPERTIES" text,
    "ENCODING_TYPE" text,
    "METADATA" text
);


ALTER TABLE public."ACTUATORS" OWNER TO sensorthings;

--
-- Name: DATASTREAMS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."DATASTREAMS" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "NAME" text,
    "DESCRIPTION" text,
    "OBSERVATION_TYPE" text,
    "PHENOMENON_TIME_START" timestamp with time zone,
    "PHENOMENON_TIME_END" timestamp with time zone,
    "RESULT_TIME_START" timestamp with time zone,
    "RESULT_TIME_END" timestamp with time zone,
    "SENSOR_ID" character varying NOT NULL,
    "OBS_PROPERTY_ID" character varying NOT NULL,
    "THING_ID" character varying NOT NULL,
    "UNIT_NAME" character varying(255),
    "UNIT_SYMBOL" character varying(255),
    "UNIT_DEFINITION" character varying(255),
    "OBSERVED_AREA" public.geometry(Geometry,4326),
    "PROPERTIES" text
);


ALTER TABLE public."DATASTREAMS" OWNER TO sensorthings;

--
-- Name: FEATURES; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."FEATURES" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "NAME" text,
    "DESCRIPTION" text,
    "ENCODING_TYPE" text,
    "FEATURE" text,
    "GEOM" public.geometry(Geometry,4326),
    "PROPERTIES" text
);


ALTER TABLE public."FEATURES" OWNER TO sensorthings;

--
-- Name: HIST_LOCATIONS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."HIST_LOCATIONS" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "TIME" timestamp with time zone,
    "THING_ID" character varying NOT NULL
);


ALTER TABLE public."HIST_LOCATIONS" OWNER TO sensorthings;

--
-- Name: LOCATIONS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."LOCATIONS" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "NAME" text,
    "DESCRIPTION" text,
    "ENCODING_TYPE" text,
    "LOCATION" text,
    "GEOM" public.geometry(Geometry,4326),
    "GEN_FOI_ID" character varying,
    "PROPERTIES" text
);


ALTER TABLE public."LOCATIONS" OWNER TO sensorthings;

--
-- Name: LOCATIONS_HIST_LOCATIONS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."LOCATIONS_HIST_LOCATIONS" (
    "LOCATION_ID" character varying NOT NULL,
    "HIST_LOCATION_ID" character varying NOT NULL
);


ALTER TABLE public."LOCATIONS_HIST_LOCATIONS" OWNER TO sensorthings;

--
-- Name: MULTI_DATASTREAMS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."MULTI_DATASTREAMS" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "NAME" text,
    "DESCRIPTION" text,
    "OBSERVATION_TYPES" text,
    "PHENOMENON_TIME_START" timestamp with time zone,
    "PHENOMENON_TIME_END" timestamp with time zone,
    "RESULT_TIME_START" timestamp with time zone,
    "RESULT_TIME_END" timestamp with time zone,
    "SENSOR_ID" character varying NOT NULL,
    "THING_ID" character varying NOT NULL,
    "UNIT_OF_MEASUREMENTS" text,
    "OBSERVED_AREA" public.geometry(Geometry,4326),
    "PROPERTIES" text
);


ALTER TABLE public."MULTI_DATASTREAMS" OWNER TO sensorthings;

--
-- Name: MULTI_DATASTREAMS_OBS_PROPERTIES; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."MULTI_DATASTREAMS_OBS_PROPERTIES" (
    "MULTI_DATASTREAM_ID" character varying NOT NULL,
    "OBS_PROPERTY_ID" character varying NOT NULL,
    "RANK" integer NOT NULL
);


ALTER TABLE public."MULTI_DATASTREAMS_OBS_PROPERTIES" OWNER TO sensorthings;

--
-- Name: OBS_PROPERTIES; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."OBS_PROPERTIES" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "NAME" text,
    "DEFINITION" text,
    "DESCRIPTION" text,
    "PROPERTIES" text
);


ALTER TABLE public."OBS_PROPERTIES" OWNER TO sensorthings;

--
-- Name: SENSORS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."SENSORS" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "NAME" text,
    "DESCRIPTION" text,
    "ENCODING_TYPE" text,
    "METADATA" text,
    "PROPERTIES" text
);


ALTER TABLE public."SENSORS" OWNER TO sensorthings;

--
-- Name: TASKINGCAPABILITIES; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."TASKINGCAPABILITIES" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "NAME" text,
    "DESCRIPTION" text,
    "PROPERTIES" text,
    "TASKING_PARAMETERS" text,
    "ACTUATOR_ID" character varying NOT NULL,
    "THING_ID" character varying NOT NULL
);


ALTER TABLE public."TASKINGCAPABILITIES" OWNER TO sensorthings;

--
-- Name: TASKS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."TASKS" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "CREATION_TIME" timestamp with time zone,
    "TASKING_PARAMETERS" text,
    "TASKINGCAPABILITY_ID" character varying NOT NULL
);


ALTER TABLE public."TASKS" OWNER TO sensorthings;

--
-- Name: THINGS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."THINGS" (
    "ID" character varying DEFAULT public.uuid_generate_v1mc() NOT NULL,
    "NAME" text,
    "DESCRIPTION" text,
    "PROPERTIES" text
);


ALTER TABLE public."THINGS" OWNER TO sensorthings;

--
-- Name: THINGS_LOCATIONS; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public."THINGS_LOCATIONS" (
    "THING_ID" character varying NOT NULL,
    "LOCATION_ID" character varying NOT NULL
);


ALTER TABLE public."THINGS_LOCATIONS" OWNER TO sensorthings;

--
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


ALTER TABLE public.databasechangelog OWNER TO sensorthings;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: public; Owner: sensorthings
--

CREATE TABLE public.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE public.databasechangeloglock OWNER TO sensorthings;

--
-- Name: ACTUATORS ACTUATORS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."ACTUATORS"
    ADD CONSTRAINT "ACTUATORS_PKEY" PRIMARY KEY ("ID");


--
-- Name: DATASTREAMS DATASTREAMS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."DATASTREAMS"
    ADD CONSTRAINT "DATASTREAMS_PKEY" PRIMARY KEY ("ID");


--
-- Name: FEATURES FEATURES_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."FEATURES"
    ADD CONSTRAINT "FEATURES_PKEY" PRIMARY KEY ("ID");


--
-- Name: HIST_LOCATIONS HIST_LOCATIONS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."HIST_LOCATIONS"
    ADD CONSTRAINT "HIST_LOCATIONS_PKEY" PRIMARY KEY ("ID");


--
-- Name: LOCATIONS_HIST_LOCATIONS LOCATIONS_HIST_LOCATIONS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."LOCATIONS_HIST_LOCATIONS"
    ADD CONSTRAINT "LOCATIONS_HIST_LOCATIONS_PKEY" PRIMARY KEY ("LOCATION_ID", "HIST_LOCATION_ID");


--
-- Name: LOCATIONS LOCATIONS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."LOCATIONS"
    ADD CONSTRAINT "LOCATIONS_PKEY" PRIMARY KEY ("ID");


--
-- Name: MULTI_DATASTREAMS_OBS_PROPERTIES MULTI_DATASTREAMS_OBS_PROPERTIES_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."MULTI_DATASTREAMS_OBS_PROPERTIES"
    ADD CONSTRAINT "MULTI_DATASTREAMS_OBS_PROPERTIES_PKEY" PRIMARY KEY ("MULTI_DATASTREAM_ID", "OBS_PROPERTY_ID", "RANK");


--
-- Name: MULTI_DATASTREAMS MULTI_DATASTREAMS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."MULTI_DATASTREAMS"
    ADD CONSTRAINT "MULTI_DATASTREAMS_PKEY" PRIMARY KEY ("ID");


--
-- Name: OBS_PROPERTIES OBS_PROPERTIES_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."OBS_PROPERTIES"
    ADD CONSTRAINT "OBS_PROPERTIES_PKEY" PRIMARY KEY ("ID");


--
-- Name: SENSORS SENSORS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."SENSORS"
    ADD CONSTRAINT "SENSORS_PKEY" PRIMARY KEY ("ID");


--
-- Name: TASKINGCAPABILITIES TASKINGCAPABILITIES_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."TASKINGCAPABILITIES"
    ADD CONSTRAINT "TASKINGCAPABILITIES_PKEY" PRIMARY KEY ("ID");


--
-- Name: TASKS TASKS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."TASKS"
    ADD CONSTRAINT "TASKS_PKEY" PRIMARY KEY ("ID");


--
-- Name: THINGS_LOCATIONS THINGS_LOCATIONS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."THINGS_LOCATIONS"
    ADD CONSTRAINT "THINGS_LOCATIONS_PKEY" PRIMARY KEY ("THING_ID", "LOCATION_ID");


--
-- Name: THINGS THINGS_PKEY; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."THINGS"
    ADD CONSTRAINT "THINGS_PKEY" PRIMARY KEY ("ID");


--
-- Name: databasechangeloglock pk_databasechangeloglock; Type: CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public.databasechangeloglock
    ADD CONSTRAINT pk_databasechangeloglock PRIMARY KEY (id);


--
-- Name: DATASTREAMS_OBS_PROPERTY_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "DATASTREAMS_OBS_PROPERTY_ID" ON public."DATASTREAMS" USING btree ("OBS_PROPERTY_ID");


--
-- Name: DATASTREAMS_SENSOR_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "DATASTREAMS_SENSOR_ID" ON public."DATASTREAMS" USING btree ("SENSOR_ID");


--
-- Name: DATASTREAMS_THING_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "DATASTREAMS_THING_ID" ON public."DATASTREAMS" USING btree ("THING_ID");


--
-- Name: HIST_LOCATIONS_THING_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "HIST_LOCATIONS_THING_ID" ON public."HIST_LOCATIONS" USING btree ("THING_ID");


--
-- Name: LOCATIONS_HIST_LOCATIONS_HIST_LOCATION_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "LOCATIONS_HIST_LOCATIONS_HIST_LOCATION_ID" ON public."LOCATIONS_HIST_LOCATIONS" USING btree ("HIST_LOCATION_ID");


--
-- Name: LOCATIONS_HIST_LOCATIONS_LOCATION_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "LOCATIONS_HIST_LOCATIONS_LOCATION_ID" ON public."LOCATIONS_HIST_LOCATIONS" USING btree ("LOCATION_ID");


--
-- Name: MDOP_MULTI_DATASTREAM_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "MDOP_MULTI_DATASTREAM_ID" ON public."MULTI_DATASTREAMS_OBS_PROPERTIES" USING btree ("MULTI_DATASTREAM_ID");


--
-- Name: MDOP_OBS_PROPERTY_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "MDOP_OBS_PROPERTY_ID" ON public."MULTI_DATASTREAMS_OBS_PROPERTIES" USING btree ("OBS_PROPERTY_ID");


--
-- Name: MULTI_DATASTREAMS_SENSOR_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "MULTI_DATASTREAMS_SENSOR_ID" ON public."MULTI_DATASTREAMS" USING btree ("SENSOR_ID");


--
-- Name: MULTI_DATASTREAMS_THING_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "MULTI_DATASTREAMS_THING_ID" ON public."MULTI_DATASTREAMS" USING btree ("THING_ID");


--
-- Name: TASKINGCAPABILITIES_ACTUATOR_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "TASKINGCAPABILITIES_ACTUATOR_ID" ON public."TASKINGCAPABILITIES" USING btree ("ACTUATOR_ID");


--
-- Name: TASKINGCAPABILITIES_THING_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "TASKINGCAPABILITIES_THING_ID" ON public."TASKINGCAPABILITIES" USING btree ("THING_ID");


--
-- Name: TASKS_TASKINGCAPABILITY_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "TASKS_TASKINGCAPABILITY_ID" ON public."TASKS" USING btree ("TASKINGCAPABILITY_ID");


--
-- Name: THINGS_LOCATIONS_LOCATION_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "THINGS_LOCATIONS_LOCATION_ID" ON public."THINGS_LOCATIONS" USING btree ("LOCATION_ID");


--
-- Name: THINGS_LOCATIONS_THING_ID; Type: INDEX; Schema: public; Owner: sensorthings
--

CREATE INDEX "THINGS_LOCATIONS_THING_ID" ON public."THINGS_LOCATIONS" USING btree ("THING_ID");


--
-- Name: DATASTREAMS DATASTREAMS_OBS_PROPERTY_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."DATASTREAMS"
    ADD CONSTRAINT "DATASTREAMS_OBS_PROPERTY_ID_FKEY" FOREIGN KEY ("OBS_PROPERTY_ID") REFERENCES public."OBS_PROPERTIES"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DATASTREAMS DATASTREAMS_SENSOR_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."DATASTREAMS"
    ADD CONSTRAINT "DATASTREAMS_SENSOR_ID_FKEY" FOREIGN KEY ("SENSOR_ID") REFERENCES public."SENSORS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DATASTREAMS DATASTREAMS_THING_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."DATASTREAMS"
    ADD CONSTRAINT "DATASTREAMS_THING_ID_FKEY" FOREIGN KEY ("THING_ID") REFERENCES public."THINGS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HIST_LOCATIONS HIST_LOCATIONS_THING_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."HIST_LOCATIONS"
    ADD CONSTRAINT "HIST_LOCATIONS_THING_ID_FKEY" FOREIGN KEY ("THING_ID") REFERENCES public."THINGS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: LOCATIONS_HIST_LOCATIONS LOCATIONS_HIST_LOCATIONS_HIST_LOCATION_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."LOCATIONS_HIST_LOCATIONS"
    ADD CONSTRAINT "LOCATIONS_HIST_LOCATIONS_HIST_LOCATION_ID_FKEY" FOREIGN KEY ("HIST_LOCATION_ID") REFERENCES public."HIST_LOCATIONS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: LOCATIONS_HIST_LOCATIONS LOCATIONS_HIST_LOCATIONS_LOCATION_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."LOCATIONS_HIST_LOCATIONS"
    ADD CONSTRAINT "LOCATIONS_HIST_LOCATIONS_LOCATION_ID_FKEY" FOREIGN KEY ("LOCATION_ID") REFERENCES public."LOCATIONS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MULTI_DATASTREAMS_OBS_PROPERTIES MDOP_MULTI_DATASTREAM_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."MULTI_DATASTREAMS_OBS_PROPERTIES"
    ADD CONSTRAINT "MDOP_MULTI_DATASTREAM_ID_FKEY" FOREIGN KEY ("MULTI_DATASTREAM_ID") REFERENCES public."MULTI_DATASTREAMS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MULTI_DATASTREAMS_OBS_PROPERTIES MDOP_OBS_PROPERTY_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."MULTI_DATASTREAMS_OBS_PROPERTIES"
    ADD CONSTRAINT "MDOP_OBS_PROPERTY_ID_FKEY" FOREIGN KEY ("OBS_PROPERTY_ID") REFERENCES public."OBS_PROPERTIES"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MULTI_DATASTREAMS MULTI_DATASTREAMS_SENSOR_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."MULTI_DATASTREAMS"
    ADD CONSTRAINT "MULTI_DATASTREAMS_SENSOR_ID_FKEY" FOREIGN KEY ("SENSOR_ID") REFERENCES public."SENSORS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MULTI_DATASTREAMS MULTI_DATASTREAMS_THING_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."MULTI_DATASTREAMS"
    ADD CONSTRAINT "MULTI_DATASTREAMS_THING_ID_FKEY" FOREIGN KEY ("THING_ID") REFERENCES public."THINGS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TASKINGCAPABILITIES TASKINGCAPABILITIES_ACTUATOR_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."TASKINGCAPABILITIES"
    ADD CONSTRAINT "TASKINGCAPABILITIES_ACTUATOR_ID_FKEY" FOREIGN KEY ("ACTUATOR_ID") REFERENCES public."ACTUATORS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TASKINGCAPABILITIES TASKINGCAPABILITIES_THING_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."TASKINGCAPABILITIES"
    ADD CONSTRAINT "TASKINGCAPABILITIES_THING_ID_FKEY" FOREIGN KEY ("THING_ID") REFERENCES public."THINGS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TASKS TASKS_TASKINGCAPABILITY_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."TASKS"
    ADD CONSTRAINT "TASKS_TASKINGCAPABILITY_ID_FKEY" FOREIGN KEY ("TASKINGCAPABILITY_ID") REFERENCES public."TASKINGCAPABILITIES"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: THINGS_LOCATIONS THINGS_LOCATIONS_LOCATION_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."THINGS_LOCATIONS"
    ADD CONSTRAINT "THINGS_LOCATIONS_LOCATION_ID_FKEY" FOREIGN KEY ("LOCATION_ID") REFERENCES public."LOCATIONS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: THINGS_LOCATIONS THINGS_LOCATIONS_THING_ID_FKEY; Type: FK CONSTRAINT; Schema: public; Owner: sensorthings
--

ALTER TABLE ONLY public."THINGS_LOCATIONS"
    ADD CONSTRAINT "THINGS_LOCATIONS_THING_ID_FKEY" FOREIGN KEY ("THING_ID") REFERENCES public."THINGS"("ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: sensorthings
--

GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

