FROM openjdk:8-jdk-alpine
LABEL author='Sunil'
COPY ./target/SpringRest-1.0-SNAPSHOT.jar /app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
