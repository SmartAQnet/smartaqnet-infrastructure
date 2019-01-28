# frost-bridge

FROST-Server with [java-mqtt-kafka-bridge](https://github.com/SmartAQnet/java-mqtt-kafka-bridge) (a bridge between a FROST-Server and Apache Kafka).

## Setup

1. Change `serviceRootUrl` in [`docker-compose.yml`](https://github.com/apm1467/frost-bridge/blob/master/docker-compose.yml) to be the address of your server, e.g.
```
serviceRootUrl=http://example.com/FROST-Server 
```

2. Edit [`java-mqtt-kafka-bridge/jmkb.properties`](https://github.com/apm1467/frost-bridge/blob/master/java-mqtt-kafka-bridge/jmkb.properties) to specify the remote Kafka server address

3. `$ docker-compose up -d` 

The bridge will now automatically connect to the Kafka server.
