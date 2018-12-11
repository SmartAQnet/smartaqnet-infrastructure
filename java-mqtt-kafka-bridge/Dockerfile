FROM maven:3-jdk-8-alpine

COPY . /java-mqtt-kafka-bridge
WORKDIR /java-mqtt-kafka-bridge
RUN mvn clean install -DskipTests

CMD java -jar target/*.jar
