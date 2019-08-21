#!/bin/sh

# update PGDATA variable for this script
if [[ -z "${PGDATA}" ]]; then
  echo "SmartAQNet DEBUG: \$PGDATA not set ... falling bach to default"
  PGDATA="/var/lib/postgresql/data"
fi

write_pg_hba_conf() {
  FILE="${PGDATA}/pg_hba.conf"
  echo "" > ${FILE}
  cat >> ${FILE} <<EOF
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
host all all 192.168.0.0/24 md5
EOF
  for name in ${POSTGRES_REPLICATION_HOSTS}; do
    echo "hostssl ${POSTGRES_REPLICATION_USER} all ${name}/32 md5" >> ${FILE}
  done 
}

enable_postgresql_ssl() {
  FILE="${PGDATA}/postgresql.conf"
  echo "ssl = on" >> ${FILE}
  echo "ssl_cert_file = '/etc/certs/cert.pem'" >> ${FILE}
  echo "ssl_key_file = '/etc/certs/psqlkey.pem'" >> ${FILE}
  echo "ssl_ca_file = '/etc/certs/fullchain.pem'" >> ${FILE}
  echo "password_encryption = on" >> ${FILE}
}

enable_postgresql_replication() {
  FILE="${PGDATA}/postgresql.conf"
  cat >> ${FILE} <<EOF
wal_level = hot_standby
archive_mode = on
archive_command = 'cd .'
max_wal_senders = 8
wal_keep_segments = 8
hot_standby = on
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
  write_pg_hba_conf
  enable_postgresql_ssl
  enable_postgresql_replication
elif [[ -z "${POSTGRES_MASTER}" ]]; then
  echo "No master server specified or not set as master!"
  exit 1
else 
  echo "TBD"
  exit 1
fi
echo "SmartAQNet Replication and SQL init done"
exit 0
