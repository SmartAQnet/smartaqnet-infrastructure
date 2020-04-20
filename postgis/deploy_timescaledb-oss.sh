#!/bin/bash
cd timescaledb-docker/postgis
make clean
make PG_VER=pg11-oss ORG=registry.teco.edu/smartaqnet push