FROM maven:3-jdk-8-alpine

RUN mkdir -p /java-mqtt-kafka-bridge
WORKDIR /java-mqtt-kafka-bridge

COPY pom.xml /java-mqtt-kafka-bridge/pom.xml
RUN mvn verify clean --fail-never

COPY . /java-mqtt-kafka-bridge
RUN mvn clean install -DskipTests

CMD java -jar target/*.jar
