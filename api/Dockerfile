FROM maven:3-jdk-8-slim as build

WORKDIR /app
COPY pom.xml .
COPY src src
RUN mvn package -DskipTests

FROM openjdk:8-jre-slim

ENV SPRING_OUTPUT_ANSI_ENABLED=ALWAYS \
    WAIT_FOR_ES=10

WORKDIR /app
EXPOSE 8080
COPY --from=build /app/target/api-1.0-SNAPSHOT.jar /app/app.jar

CMD echo "The application will start in ${WAIT_FOR_ES}s..." && \
    sleep ${WAIT_FOR_ES} && \
    java -Djava.security.egd=file:/dev/./urandom -jar app.war