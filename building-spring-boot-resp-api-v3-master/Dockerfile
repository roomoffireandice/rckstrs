FROM maven:3-jdk-8 as mvn
LABEL author='Sunil'
RUN git clone https://github.com/sunildasu1234/Hellonodejs.git && cd /Hellonodejs/building-spring-boot-resp-api-v3-master && mvn clean package
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} SpringRest-1.0-SNAPSHOT.jar
ENTRYPOINT ["java","-jar","/SpringRest-1.0-SNAPSHOT.jar"]