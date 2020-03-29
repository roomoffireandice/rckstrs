In order to achieve this requirement, first I had dockerized the applications (Springboot Java Applicationd and MYSQL database ) prior to deploying in Kubernetes Infrastructure. Below are the steps 

Accessing the Application using Docker Containers:
--------------------------------------------------

I have two docker containers running with Spring boot java Application and MqSql database. In order to access the Application I followed below steps to achieve.

```
* Below are teh the steps to Create MQSQL Docker image  
        1) Taken MQSQL base image from Dokcer Hub Registry (https://hub.docker.com/_/mysql/)
        2) Created the container by passing environment variables and base image
              ```
              docker run -d -p 3306:3306 --name=mysqlsvc --env="MYSQL_ROOT_PASSWORD=Newuser@123" --env="MYSQL_PASSWORD=Newuser@123" --env="MYSQL_DATABASE=test" mysql:5.6

              ```
      3) Created the datbase and created the table and inserted the content inside table
      4) Then I have committed the changes and created customized MySQL images and pushed to Docker Hub registry.

              ```
              Docker commit:
                docker commit mysqlsvc

              Docker tag:
                docker tag dde323c58722 sunilkumardasu/mysql:latest

              Docker push:
                docker push sunilkumardasu/mysql

              ```
```
Setting up Springboot Application to invoke Above MYSQL database

```
     1) In the Springboot Java Application, I have used the same container name "mysqlsvc" in the application.properties file.                 spring.datasource.url=jdbc:mysql://mysqlsvc:3306/test

     2) Using maven, I had compiled code and created the Springboot artifact.
     3) Created below Dockerfile for Springboot Java Application 

            ```
            FROM openjdk:8-jdk-alpine
            LABEL author='Sunil'
            COPY ./target/SpringRest-1.0-SNAPSHOT.jar app.jar
            EXPOSE 8080
            ENTRYPOINT ["java","-jar","/app.jar"]

            ```
     4)  Building the Springboot Application Image and pushed the docker image to Docker Hub registry

            ```
            docker build -t sunilkumardasu/hellonodejs:$BUILD_NUMBER <directory_path>
            docker push sunilkumardasu/hellonodejs:$BUILD_NUMBER

            ```

     5)  In Order to access the Application we need ot link  mysql database with Springboot Application

            ```
            docker run -p 8080:8080 --name hellonodejs --link mysqlsvc:mysql sunilkumardasu/hellonodejs:$BUILD_NUMBER

            ```
```
Accessing the Application using Kubernetes Cluster and below are the steps:
---------------------------------------------------------------------------

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
* Below is the kubernetes mysqldeployment.yml and hellodeployment.yml file. Using following files we can spinup 2 pods.

* Below is the mysqldeployment.yml file which pulls the customised mysql image from dockerhub registry "sunilkumardasu/mysql"
  and service.yml file with type clusterIP and port 3306.

```
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-demo
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deploy
spec:
  minReadySeconds: 10
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
        - name: mysql
          image: sunilkumardasu/mysql
          command: ["/bin/sh", "-ce", "tail -f /dev/null"]
          ports:
            - containerPort: 3306
              protocol: TCP
          volumeMounts:
            - mountPath: /var/lib/mysql
              name: mysqlvolume
          env:
            - name: MYSQL_DATABASE
              value: 'test'
            - name: MYSQL_USER
              value: 'root'
            - name: MYSQL_PASSWORD
              value: 'Newuser@123'
            - name: MYSQL_ROOT_PASSWORD
              value: 'Newuser@123'
      volumes:
      - name: mysqlvolume
        persistentVolumeClaim:
          claimName: pvc-demo

---
apiVersion: v1
kind: Service
metadata:
  name: mysqlsvc
spec:
  selector:
    app: db
  type: ClusterIP
  ports:
    - name: mysql
      targetPort: 3306
      port: 3306
```
* Below is the hellodeployment.yml. Using service we can access Hellonodejs application using nodeport IP address with port "30001"

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
        image: sunilkumardasu/hellonodejs:$BUILD_NUMBER
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

* I tried to access the Application using Node port. In order to access the application using NodePort from out side the Kubernetes cluster,I have enabeld the the firewall for the particular port using below command

C:\Users\Sunil Kumar\AppData\Local\Google\Cloud SDK>gcloud compute firewall-rules create my-rule-k8s --allow=tcp:30001
Creating firewall...|Created [https://www.googleapis.com/compute/v1/projects/hopeful-host-271811/global/firewalls/my-rule-k8s].
Creating firewall...done.
NAME         NETWORK  DIRECTION  PRIORITY  ALLOW      DENY  DISABLED
my-rule-k8s  default  INGRESS    1000      tcp:30001        False

C:\Users\Sunil Kumar\AppData\Local\Google\Cloud SDK>

Once enabled port (30001) ,I was able to access the application using this URL (http://Node_public_ip:30001/blog)


Even i tired to expose the service using load balance.I was able to access the application using this URL (htts://loadbalancer_ip:8080/blog)

```
apiVersion: v1
kind: Service
metadata:
  name:  hellonode-svc
spec:
  selector:
    app:  hello-node-k8s
  type: LoadBalancer
  ports:
  - name:  http
    port:  8080
    protocol: TCP

```
```
{"Message":"HelloNodeJSWorld"}

```

Jenkinsfile:
------------
* Following Jenkins file would clone the Dockerfile and SpringRest-1.0-SNAPSHOT.jar file form the git repository and then
  dockerize (create the  image) and then push to docker hub repository.
  Later this jenkins file would call above mysqldeployment.yml and hellodeployment.yaml file. This yml files will create pods and service.
  Using loadbalancer we can access deployed application (http://<LoadbalancerIp>:port)

```
  pipeline
	{
    environment {
      build_branch = 'master'
    //repo_name = 'Hellonodejs'
	    target = '/var/lib/jenkins/workspace/Hellonodejs'
	    registry = "sunilkumardasu/hellonodejs"
      registryCredential = 'dockerhub'
    }
		agent { label 'master' }
		stages
		{
			stage('SCM CHECKOUT')
			{
				steps
				{
					echo env.build_branch + 'master'
					echo env.repo_name + "Hellonodejs"
					git changelog: false, credentialsId: 'github', poll: true, url: "https://github.com/sunildasu1234/Hellonodejs.git", branch: env.build_branch

				}
			}
            stage('Build the artifact')
            			{
            				steps
            				{
            					sh '/usr/bin/mvn clean install -DskipTests=true'
            				}
            			}
    	
			stage('Docker Image Build')
					{
						steps
						{
								script
								{
									sh "hostname"
									sh "pwd"

									pom = readMavenPom file: 'pom.xml'
									echo pom.version
									echo pom.artifactId
									echo pom.packaging

									sh "docker build -f ${env.target}/Dockerfile -t sunilkumardasu/hellonodejs:${BUILD_NUMBER} --no-cache ."
								}
						}
					}
			
			stage('Push the docker Image') 
			       {
						  steps
						  {
							script 
							{
							  docker.withRegistry( '', registryCredential ) 
								  {
								  sh "docker push sunilkumardasu/hellonodejs:${BUILD_NUMBER}"
								  }
							}
						  }
                   }
			stage('Remove Unused docker image') 
			
				{
				  steps
					  {
						sh "docker rmi $registry:$BUILD_NUMBER"
					  }
			    }
				
			stage('DeploymysqlToK8SCluster') 
			
			   {
                 steps 
				 
				     {
					 
                        kubernetesDeploy(kubeconfigId:'mykubeconfig',configs:'mysqldeployment.yml',enableConfigSubstitution:true)
                     
					 }
					
			   }
			   
			stage('DeployhellonodejsToK8SCluster') 
			
			   {
                 steps 
				 
				    {
				          kubernetesDeploy(kubeconfigId:'mykubeconfig',configs:'hellodeployment.yml',enableConfigSubstitution:true)
                    }
			   } 
		}
}
```

* In order to access above deployed Hellonodejs World micro service, we need to use this URL http://<Loadbalancer>:<<port>> in your browser, you should be able to see as below 

```
{"Message":"HelloNodeJSWorld"}

```



