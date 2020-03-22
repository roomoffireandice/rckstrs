FROM openjdk:8-jdk-alpine
LABEL author='Sunil'
EXPOSE 8086
COPY /SpringRest-1.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]
EXPOSE 8080
