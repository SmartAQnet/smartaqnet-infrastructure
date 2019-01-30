Clone using `$git clone --recursive git@github.com:SmartAQnet/frost-bridge.git` (you need to setup ssh key at github)

# frost-bridge

FROST-Server with [java-mqtt-kafka-bridge](https://github.com/SmartAQnet/java-mqtt-kafka-bridge) (a bridge between a FROST-Server and Apache Kafka).

## Setup

1. edit .env to set hostname 

2. `$ docker-compose up -d` 

The bridge will now automatically connect to the Kafka server.

## Cleanup

1. `$ docker-compose down -v`
