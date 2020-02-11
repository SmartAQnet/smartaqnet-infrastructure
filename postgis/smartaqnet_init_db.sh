#!/bin/sh

# update PGDATA variable for this script
if [[ -z "${PGDATA}" ]]; then
  echo "SmartAQNet DEBUG: \$PGDATA not set ... falling bach to default"
  PGDATA="/var/lib/postgresql/data"
fi

write_pg_hba_conf() {
  FILE="${PGDATA}/pg_hba.conf"
  cat > ${FILE} <<EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
#local   replication     postgres                                trust
#host    replication     postgres        127.0.0.1/32            trust
#host    replication     postgres        ::1/128                 trust

host all all 10.0.0.0/8 md5
host all all 172.16.0.0/12 md5
host all all 192.168.0.0/16 md5
host replication all 10.0.0.0/8 md5
host replication all 172.16.0.0/12 md5
host replication all 192.168.0.0/16 md5
EOF
}

enable_postgresql_replication() {
  FILE="${PGDATA}/postgresql.conf"
  cat >> ${FILE} <<EOF
wal_level = hot_standby
archive_mode = on
archive_command = 'cd .'
max_wal_senders = 8
wal_keep_segments = 24
hot_standby = on
vacuum_defer_cleanup_age = 20
EOF
}

load_basebackup() {
  echo "Loading master's basebackup. If this takes too long maybe this server cannot reach the master"
  rm -rf ${PGDATA}/*
  until pg_basebackup -v -P -X stream -D ${PGDATA} -d "${PG_CONN_STRING}"; do
    echo "Trying to connect to master..."
    sleep 1s
  done
}

enable_postgresql_replication_backup() {
  FILE="${PGDATA}/recovery.conf"
  cat > ${FILE} <<EOF
standby_mode = on
primary_conninfo = '${PG_CONN_STRING}'
trigger_file = '${PGDATA}/promote_master_touch'
EOF
  #sed -i 's/wal_level = hot_standby/wal_level = replica/g'
}

enable_postgresql_replication_feedback() {
  FILE="${PGDATA}/postgresql.conf"
  cat >> ${FILE} <<EOF
hot_standby_feedback = on
EOF
}

# initialise the uuid-ossp extension in order to use UUIDs as ID
# and add replication user
psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<EOSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE USER ${POSTGRES_REPLICATION_USER} REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '${POSTGRES_REPLICATION_PASSWORD}';
EOSQL

# update postgres configs
if [[ "${POSTGRES_REPLICATION_MASTER}" == "true" ]]; then
  echo "SmartAQNet PostGis configuring master server"
  write_pg_hba_conf
  enable_postgresql_replication
else 
  echo "SmartAQNet PostGis configuring hot standby server"
  pg_ctl stop
  PG_CONN_STRING="host=${POSTGRES_REPLICATION_MASTER_HOST} port=5432 user=${POSTGRES_REPLICATION_USER} password=${POSTGRES_REPLICATION_PASSWORD}"
  echo "Connection string is: ${PG_CONN_STRING}"
  write_pg_hba_conf
  load_basebackup
  enable_postgresql_replication_backup
  enable_postgresql_replication_feedback
  pg_ctl start -w -D ${PGDATA} 
fi
echo "SmartAQNet Replication and SQL init done"
exit 0
