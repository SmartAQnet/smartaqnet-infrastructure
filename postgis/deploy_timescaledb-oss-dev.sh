#!/bin/bash
cd timescaledb-docker/postgis
make clean
make PG_VER=pg11-oss ORG=swarm-manager-1:5001/smartaqnet push