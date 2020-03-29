Spring Boot on Docker connecting to MySQL Docker container

* Use MySQL Image published by Docker Hub (https://hub.docker.com/_/mysql/) Command to run the mysql container.
```
docker run -d -p 3306:3306 --name=mysql --env="MYSQL_ROOT_PASSWORD=Newuser@123" --env="MYSQL_PASSWORD=Newuser@123" --env="MYSQL_DATABASE=test" mysql:5.6

```

* In the Spring Boot Application, use the same container name of the mysql instance in the application.properties spring.datasource.url=jdbc:mysql://mysql:3306/test

* Create a Dockerfile for creating a docker image from the Spring Boot Application.

```
FROM openjdk:8-jdk-alpine
LABEL author='Sunil'
COPY ./target/SpringRest-1.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]

```
* Now build the image and push the docker image to docker hub
```
docker build -t sunilkumardasu/hellonodejs:14 <directory_path>
docker push sunilkumardasu/hellonodejs:14

```

* Link the mysql database with application,

```
docker run -p 8080:8080 --name hellonodejs --link mysql:mysql:5.6 sunilkumardasu/hellonodejs:14

```

