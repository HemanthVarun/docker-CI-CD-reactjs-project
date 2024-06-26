# Simple React

Sample React.js application for the Docker environment.

## Getting Started
![Screen Shopt](images/screenshot.png?raw=true "Screen Shot")
App with one container. Reading from external open API. No storage. No secrets. Dynamic web page - including information from external API.

### Prerequisites

Make sure you have already installed Docker Engine.
You don’t need to install Nginx or NPM, as both are provided by Docker images.

```
$ docker -v
Docker version 18.03.1-ce, build 9ee9f40
```


### Installing

```
git clone https://github.com/thejungwon/docker-reactjs.git
cd docker-reactjs
docker build -t docker-reactjs .
docker run -p 80:80 docker-reactjs

```
Go to [http://localhost](http://localhost)

## Running the tests

TBD

### Break down into end to end tests

TBD

### And coding style tests

TBD


## Built With

* [Nginx](https://nginx.org/en/) - Web server
* [React.js](https://reactjs.org/) - The front-end framework used
* [Docker](https://www.docker.com/) - Containerization
* [Materialize](https://materializecss.com/) - Front-end framework


## Authors

* **Jungwon Seo** - *Initial work* - [thejungwon](https://github.com/thejungwon)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details















# CI-CD--Project
**Build a CI/CD project using Jenkins and EKS Cluster.**

**Prerequisites:**

An AWS account with administrative privileges.
A GitHub account.
Terraform Installation for automating the deployment.
Docker Installation.
Jenkins Installation. 

**Steps:**
**1. Configure an EC2 Instance in AWS**
   
   Launch a new EC2 instance based on your preferred configuration by taking the Ubunut AMI.


**2. Install Java on Ubuntu 22.04**
   
   Connect to your EC2 instance via SSH.
   Update package lists and install Java 17.


**3. Install Jenkins on Ubuntu 22.04**
  
   Add the Jenkins repository key and source list.
   Update package lists and install Jenkins.


**4. Enable and Start Jenkins**

   Enable Jenkins to start at boot time and start the service.
   Check the status of Jenkins service.
   Install Git on Ubuntu 22.04 LTS


**5. Install Git using the apt package manager**

   Access Jenkins Web Interface


**6. Open your web browser and navigate to http://<your_instance_ip>:8080**

   Retrieve the initial administrator password using the provided command and paste it into the browser prompt.


**7. Configure Jenkins User and Credentials**

   GO to the Manage Jenkins>>Credentials>>system>>Global credentials, add the necessary credentials.


**8. Install Docker in Ubuntu 22.04**

   sudo apt install docker.io                                                                 # Install the Docker, for jenkins to interact with the Docker
   sudo usermod -aG docker $USER                                                              # Grant your user permission to run Docker commands:
   sudo chmod 666 /var/run/docker.sock                                                        # Change permissions for the Docker socket:
   sudo systemctl restart jenkins                                                             # Restart Jenkins:

**9. Install Jenkins Plugins**

   In Jenkins, go to "Manage Jenkins" -> "Plugins" -> "Available Plugins".
   Install the following plugins:
   - Docker
   - Docker Pipeline
   - Amazon ECR
   Create an ECR Repository in AWS
   Go to the AWS Management Console and navigate to the ECR service.
   Click "Create repository" and provide a name for your repository.
   Create an IAM Role with AmazonEC2ContainerRegistryFullAccess Policy
   In the AWS Management Console, navigate to the IAM service.
   Create a new role with the "AmazonEC2ContainerRegistryFullAccess" policy attached.          # this attached to EC2 instance where jenkins installed, because jenkins to authenticate the ECR registry to push the image.

**10. Install the AWS CLI on Ubuntu 22.04:**

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"          # Download the AWS CLI installation package from the official AWS website
    unzip awscliv2.zip                                                                         # Unzip the downloaded package
    sudo ./aws/install                                                                         # Install the AWS CLI

**11. Create a Jenkins Pipeline:**
    Go to the Jenkins dashboard.
    Click on "New Item" and select "Pipeline".
    Provide a name for your pipeline job.
    In the "Pipeline" definition, paste the following code snippet, replacing placeholders with your specific values
    **Follow this Groovy script for the pipline build process:**

    pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="222222222222"                                                                                        # Replace with your AWS account ID
        AWS_DEFAULT_REGION="ap-south-1"
        IMAGE_REPO_NAME="jenkins-pipeline"
        IMAGE_TAG="v1"
        REPOSITORY_URI = "22222222222.dkr.ecr.us-east-1.amazonaws.com/jenkins-pipeline"                                      # Replace with your ERC image URL
    }
   
    stages {
        
         stage('Logging into AWS ECR') {
            steps {
                script {
                sh """aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"""
                }
                 
            }
        }
        
        stage('Cloning Git') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/sd031/aws_codebuild_codedeploy_nodeJs_demo.git']]])     
            }
        }
  
    // Building Docker images
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
        }
      }
    }
   
    // Uploading Docker images into AWS ECR
    stage('Pushing to ECR') {
     steps{  
         script {
                sh """docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"""
                sh """docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"""
         }
        }
      }
    }
}

Lastely, You can verify in the AWS account, wheather ECR images is been pushed.

**The following process regarding to the CD part, where we Deploy the AWS ECR image to the EKS Cluster, using Terraform Automation Code.**

**12. Launch a EC2 machine and run the following command to install terraform**

      1. sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
      2. wget -O- https://apt.releases.hashicorp.com/gpg | \
         gpg --dearmor | \
         sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
      3. gpg --no-default-keyring \
         --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
         --fingerprint

**13. Install AWS CLI:**

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install.

**14. Execute the main.tf file provided above to deploy the ERC image to EKS cluster**


**15. Configure the Load balancer endpoint to EKS Worker node:**

     1. Access the Load Balancer Service:
         Log in to your cloud provider's management console.
         Navigate to the section dedicated to Load Balancing services.
         Create a Load Balancer:

     2. Click on "Create Load Balancer" or a similar option.
         Choose an appropriate load balancer type (e.g., Application Load Balancer for HTTP/HTTPS traffic).
         Provide a name for your load balancer.
         Configure additional settings as required by your specific service (e.g., VPC configuration, security groups).

    3. Define Target Group:
        Create a new target group or select an existing one.
        A target group is a collection of instances that the load balancer will distribute traffic to.

    4. Register Instance(s):
        In the target group configuration, specify the instance(s) you want to route traffic to. This typically involves providing instance IDs or private IP addresses.

    5. Configure Load Balancer Listener:
        Define a listener on the load balancer that listens for incoming traffic on a specific port (e.g., port 80 for HTTP traffic).
        Associate the listener with the target group you created in step 3.
      
    6. Create Load Balancer Endpoint (Optional):
        Some cloud providers allow creating an endpoint for the load balancer. This endpoint serves as a single entry point for clients to access your instances.
        (Note: This step might be named differently depending on your service. It might also be part of step 2 when creating the Load Balancer.)
    





