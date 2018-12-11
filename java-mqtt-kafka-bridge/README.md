# java-mqtt-kafka-bridge
A bridge between a FROST Server and Apache Kafka, written in Java

## Build from source
Requirements:
- A working JDK. This program is not guaranteed to work properly with JDK versions below 8u171.
- Maven
- Git

On Debian/Ubuntu systems, just run `sudo apt install default-jdk maven git`.
1. Clone this repository via `git clone https://github.com/olivermliu/java-mqtt-kafka-bridge.git`.
2. `cd java-mqtt-kafka-bridge`
3. If necessary, adjust the parameters in the jmkb.properties file (see below for more information).
4. `mvn clean install` (Note: Tests require the configuration in jmkb.properties to be valid and all services (Kafka, FROST) to be running. To skip tests, run `mvn clean install -DskipTests`).
5. Run the program with the generated jar: `java -jar target/*.jar`.

## Configuration
Set configurables in the jmkb.properties file. Please note: URIs require a `<protocol>://<address>:<port>` format.

Currently, configurables are:
- `frostServerURI`: the URI from which to get the MQTT messages of the FROST-Server. Requires `tcp://` as protocol. Usually port 1883.
- `kafkaBrokerURI`: the URI to which to send Kafka records. With Kafka Landoop, use the port defined under "Kafka Broker". Usually port 9092 and `http://` as protocol.
- `schemaRegistryURI`: the URI from which to get Avro schemas. With Kafka Landoop, use the port defined under "Schema Registry". Usually port 8081 and `http://` as protocol.
- `format`: the format in which to send MQTT messages to Kafka. Currently, the formats `avro` and `json` are supported.

## Further information
- Use `Ctrl+C` to terminate the program. This ensures that the MQTT Client and Kafka Producer disconnect properly.
- You can use a program like `screen` to open a virtual terminal and run the bridge there.

## Test data
Test data are provided in the password-protected archive TestData.7z. With this, the functionality of the program can be tested. Please make sure the bridge is running before you start step 4. You will need Python 3 to run the scripts and p7zip-full to extract the test data.

1. Run `sudo apt install p7zip-full python3 python3-pip` to install Python 3, pip and 7z.
2. Run `python3 -m pip install pandas requests` to install required modules.
3. Run `7z x TestData.7z` in the directory of `TestData.7z` to extract the scripts and test data. Enter the password when prompted.
4. Run `python3 CreateThing.py`, then `python3 CreateDatastream.py`, then `python3 AddObservationsToDatastream.py`.
5. Test data should have been successfully published to FROST.
