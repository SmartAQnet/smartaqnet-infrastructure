FROM mdillon/postgis:9.5-alpine

# copy init script so it will run automatically after startup
COPY ./smartaqnet_init_db.sh /docker-entrypoint-initdb.d/
