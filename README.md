
```
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
Kubernetes Deployment Using Jenkins Pipeline

* Deploying the Spring boot Application(SpringRest-1.0-SNAPSHOT.jar) in Kubernetes Google cloud cluster environment using Jenkins CI/CD Pipeline.Using Jenkins Pipe line, I have performed following steps to achieve this requirement.

```
1) Created following Global Credentials in Jenkins Console
		Github Credentials : For SCM checkout purpose
		Docker-registry Credentials : For publishing the docker images to dockerhub registry.
		Jenkins Credentials: Used for communication with docker
		Kubeconfig Credentials : Used for communication with Kubernetes
2) Created the Dockerfile and dockerized the SpringRest-1.0-SNAPSHOT.jar file
3) Build the image and published the image into docker registry and removed unused docker images.
5) Prepared the Kubernetes deployment,service yml files for creation of K8S Infrastructure using Jenkins Pipeline

```
Dockerfile:

* Using Dockerfile, I am able to dockerize the hellonodejs microservice 

```
FROM openjdk:8-jdk-alpine
LABEL author='Sunil'
COPY ./target/SpringRest-1.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]

```
* Below is the kubernetes hellodeployment.yml file. Using following hellodeployment.yaml file we can spinup 2 pods. Successfully deployed  above dockerized microservice into google cloud kubernetes cluster environment ( its has 2 nodes ( master,node1,node2)).

* Using service we can access Hellonodejs application using nodeport IP address with port "30001"

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hellonodejs-deployment
spec:
  minReadySeconds: 10
  replicas: 2
  selector:
    matchLabels:
      app: hello-node-k8s
  strategy:
    rollingUpdate:
      maxSurge: 35%
      maxUnavailable: 30%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: hello-node-k8s
    spec:
      containers:
      - name: hello-node-k8s
        image: sunilkumardasu/hellonodejs:14
        command: [sh, -c, "sleep 1000"]
        args: [ "while true; do sleep 30; done;" ]
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name:  hellonode-svc
spec:
  selector:
    app:  hello-node-k8s
  type:  NodePort
  ports:
  - name:  http
    port:  8080
    nodePort: 30001
    protocol: TCP

```

* Even I tried to access the Application using Node port as well. In order to access the application using NodePort from out side the Kubernetes cluster,
I have enabeld the the firewall for the perticular port using below command

C:\Users\Sunil Kumar\AppData\Local\Google\Cloud SDK>gcloud compute firewall-rules create my-rule-k8s --allow=tcp:30001
Creating firewall...|Created [https://www.googleapis.com/compute/v1/projects/hopeful-host-271811/global/firewalls/my-rule-k8s].
Creating firewall...done.
NAME         NETWORK  DIRECTION  PRIORITY  ALLOW      DENY  DISABLED
my-rule-k8s  default  INGRESS    1000      tcp:30001        False

C:\Users\Sunil Kumar\AppData\Local\Google\Cloud SDK>

Once enabled port (30001) ,I was able to access the application using this URL (http://Node_public_ip:30001/test/)





