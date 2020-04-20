--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE replication;
ALTER ROLE replication WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN REPLICATION NOBYPASSRLS CONNECTION LIMIT 100 PASSWORD 'md5c53a3d3dd43c9247725fabb08e5b6de0';
CREATE ROLE sensorthings;
ALTER ROLE sensorthings WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md543c6d6cb3f008b0826bff9db7d4d95a0';
CREATE ROLE sensorthings_timeout;
ALTER ROLE sensorthings_timeout WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5e03c908b87e9337dae30209377c34154';
ALTER ROLE sensorthings_timeout SET statement_timeout TO '600000';






--
-- PostgreSQL database cluster dump complete
--

