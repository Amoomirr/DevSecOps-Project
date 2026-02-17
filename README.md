<div align="center">
  <img src="./public/assets/output.gif" alt="Logo" width="100%" height="100%">

  <br>
  <a href="http://netflix-clone-with-tmdb-using-react-mui.vercel.app/">
    <img src="./public/assets/netflix-logo.png" alt="Logo" width="100" height="32">
  </a>
</div>


### 🚀 **Netflix DevSecOps Project**
A complete end-to-end DevSecOps pipeline for deploying a Netflix Clone application using modern DevOps and DevSecOps tools.

This project demonstrates:
- Infrastructure as Code (IaC) using Terraform
- Containerization using Docker
- CI/CD using Jenkins & GitHub Webhooks
- Security Scanning using SonarQube, Trivy & OWASP
- GitOps deployment using ArgoCD
- Kubernetes orchestration using AWS EKS 
- Monitoring using Prometheus & Grafana
- Full infrastructure cleanup using terraform destroy

### **Phase 1: Infrastructure Creation**

**Step 1: Resource Created using Terraform :**
 Provision complete AWS infrastructure including:
- EC2 instance
- VPC
- EKS cluster

![Terraform-Infra](https://github.com/user-attachments/assets/02254cca-fa55-4cd3-91c1-f323689604dd)

📦 Initialize Terraform
```bash
terraform init
terraform validate
terraform plan
terraform apply
```
![Ec2-Dashboard](https://github.com/user-attachments/assets/7786268b-5051-45f9-b6b8-b6f93be9a490)


**Step 2: Clone the Code:**

- Update all the packages and then clone the code.
- Clone your application's code repository onto the EC2 instance:
    
    ```bash
    git clone https://Amoomirr/github.com/DevSecOps-Project.git
    ```

**Step 3: Install Docker and Run the App Using a Container:**

- Set up Docker on the EC2 instance:
    
    ```bash
    
    sudo apt-get update
    sudo apt-get install docker.io -y
    sudo usermod -aG docker $USER  # Replace with your system's username, e.g., 'ubuntu'
    newgrp docker
    sudo chmod 777 /var/run/docker.sock
    ```
    
- Build and run your application using Docker containers:
    
    ```bash
    docker build -t netflix .
    docker run -d --name netflix -p 8081:80 netflix:latest
    
    #to delete
    docker stop <containerid>
    docker rmi -f netflix
    ```![without-api](https://github.com/user-attachments/assets/cd8460a6-4c2c-4687-8be8-efde5d09fcc9)

It will show error cause you need a API key

**Step 4: Get the API Key:**

- Open a web browser and navigate to TMDB (The Movie Database) website.
- Click on "Login" and create an account.
- Once logged in, go to your profile and select "Settings."
- Click on "API" from the left-side panel.
- Create a new API key by clicking "Create" and accepting the terms and conditions.
- Provide the required basic details and click "Submit."
- You will receive your TMDB API key.

Now recreate the Docker image with your API key:
```
docker build --build-arg TMDB_V3_API_KEY=<your-api-key> -t netflix .
```
![with-api](https://github.com/user-attachments/assets/c878cd44-43d3-414c-a790-ed5a36cd6229)

### **Phase 2:   Security Implementation (SonarQube & Trivy)**

 Step 1: 🛡️ SonarQube (Static Code Analysis)
 
 ```bash
  docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
 ```
        
   To access: 
   - publicIP:9000 (by default username & password is admin)
   
 Step 2: Integrate SonarQube and Configure:
    - Integrate SonarQube with your CI/CD pipeline.
    - Configure SonarQube to analyze code for quality and security issues.

![sonarqube-jenkins](https://github.com/user-attachments/assets/5c4b8990-e8bb-44c3-b2fb-a7e56bd97f0f)
   
  Step 3: 🔍 Trivy (Container Image Scanning)
      
   ```bash
        sudo apt-get install wget apt-transport-https gnupg lsb-release
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
        echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
        sudo apt-get update
        sudo apt-get install trivy
 ```
        
  to scan image using trivy
         ```bash
        trivy image <imageid>
        ```
 
![trivy-scan](https://github.com/user-attachments/assets/07083803-17c6-475c-acaa-a438f0fed8d9)


### **Phase 3: CI/CD Setup (Jenkins + GitHub)**

1. **Install Jenkins for Automation:**
    - Install Jenkins on the EC2 instance to automate deployment:
    Install Java
    
    ```bash
    sudo apt update
    sudo apt install fontconfig openjdk-17-jre
    java -version
    openjdk version "17.0.8" 2023-07-18
    OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
    OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)
    
    #jenkins
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    ```
    
    - Access Jenkins in a web browser using the public IP of your EC2 instance.
        
        publicIP:8080
        
2. **Install Necessary Plugins in Jenkins:**

Goto Manage Jenkins → Plugins → Available Plugins →

Install below plugins

1 Eclipse Temurin Installer (Install without restart)

2 SonarQube Scanner (Install without restart)

3 NODEJS Plugin (Install Without restart)

4 OWASP


**Create a Jenkins webhook**

![github-webhook](https://github.com/user-attachments/assets/7322a7b9-7994-4293-a001-2d395fdfddda)

**Configure CI/CD Pipeline in Jenkins:**

- Create a CI/CD pipeline in Jenkins to automate your application deployment.

**Install Dependency-Check Plugin:**

- Go to "Dashboard" in your Jenkins web interface.
- Navigate to "Manage Jenkins" → "Manage Plugins."
- Click on the "Available" tab and search for "OWASP Dependency-Check."
- Check the checkbox for "OWASP Dependency-Check" and click on the "Install without restart" button.

**Configure Dependency-Check Tool:**

- After installing the Dependency-Check plugin, you need to configure the tool.
- Go to "Dashboard" → "Manage Jenkins" → "Global Tool Configuration."
- Find the section for "OWASP Dependency-Check."
- Add the tool's name, e.g., "DP-Check."
- Save your settings.

**Add DockerHub Credentials:**

- To securely handle DockerHub credentials in your Jenkins pipeline, follow these steps:
  - Go to "Dashboard" → "Manage Jenkins" → "Manage Credentials."
  - Click on "System" and then "Global credentials (unrestricted)."
  - Click on "Add Credentials" on the left side.
  - Choose "Secret text" as the kind of credentials.
  - Enter your DockerHub credentials (Username and Password) and give the credentials an ID (e.g., "docker").
  - Click "OK" to save your DockerHub credentials.

You can now proceed with configuring your Jenkins pipeline to include these tools and credentials in your CI/CD process.

```groovy

pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('Clean Workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/Amoomirr/DevSecOps-Project.git'
            }
        }

         stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix '''
                }
            }
        }
        stage("Quality Gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-id' 
                }
            } 
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build & Push"){
            steps{
                script{
                   withCredentials([string(credentialsId: 'TMDB_API', variable: 'API')]) {
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker' ){   
                       sh "docker build --build-arg TMDB_V3_API_KEY=${API} -t netflix ."
                       sh "docker tag netflix amoomirr/netflix:${BUILD_NUMBER}"
                       sh "docker push amoomirr/netflix:${BUILD_NUMBER} "
                    }
                }
            }
        }
        }
        stage('Update K8s Manifest') {
                 steps {
                    withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                        git clone https://${GITHUB_TOKEN}@github.com/Amoomirr/DevSecOps-Project.git
            
                            cd Kubernetes
                            git config user.email "youremail"
                            git config user.name "jenkins"
                            sed -i "s|image: amoomirr/netflix:.*|image: amoomirr/netflix:${BUILD_NUMBER}|g" deployment.yml
                            
                            git add deployment.yml
                            git commit -m "Update image to ${BUILD_NUMBER} [skip ci]"
                            git remote set-url origin https://${GITHUB_TOKEN}@github.com/Amoomirr/DevSecOps-Project.git
                            git push -o ci.skip origin main
                            '''
                    }

    }
}
}
}

```

<img width="1339" height="643" alt="jenkins-dashboard" src="https://github.com/user-attachments/assets/9b0d34f2-d37d-4288-8990-32be13d0c6e9" />

### **Phase 4: GitOps Deployment (ArgoCD & Kubernetes)** 

Step 1 – Install AWS CLI

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
```
Step 2 – Configure AWS CLI

```bash
aws configure
```
Enter your IAM USER Access KEY

- AWS Access Key ID 
- AWS Secret Access Key
- Default region name (ap-south-1)
- Default output format (json)

 Make sure the IAM user/role has:

- EKS access
- EC2 permissions
- Cluster describe permissions

Step 3 – Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```
Step 4 – Configure kubectl for EKS

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name netflix-eks-cluster
```
Step 5 – Verify Cluster Connection

```bash
kubectl get nodes
```
If nodes are visible → ✅ Cluster is connected.

**Install ArgoCD using Helm**

Create a Namespace for Argo CD<br/>
```bash
kubectl create namespace argocd
```
1. Install Argo CD using Manifest
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
2. Watch Pod Creation
```bash
watch kubectl get pods -n argocd
```
3. This helps monitor when all Argo CD pods are up and running.<br/>

4. Check Argo CD Services
```bash
kubectl get svc -n argocd
```
5. Change Argo CD Server Service to NodePort
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```
6. Access Argo CD GUI<br/>
Check Argo CD Server Port (again, post NodePort change)<br/>
```bash
kubectl get svc -n argocd
```
1. Port Forward to Access Argo CD in Browser<br/>
```bash
kubectl port-forward svc/argocd-server -n argocd <your-port>:443 --address=0.0.0.0 &
```
2. Replace <your-port> with a local port of your choice (e.g., 8080).<br/>
 Now, open https://<bastion-ip>:<your-port> in your browser.

Get the Argo CD Admin Password<br/>
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

1. Log in to the Argo CD GUI
* Username: admin
* Password: (Use the decoded password from the previous command)

2. Update Your Password
* On the left panel of Argo CD GUI "User Info"
* Select Update Password and change it.

 **Deploy Your Application in Argo CD GUI**

> 1. On the Argo CD homepage -> “New App” .<br/>

> 2. Fill in the following details:<br/>
>  -  **Application Name:**
> `Enter your desired app name`
>  -  **Project Name:**
> Select `default` from the dropdown.
>    * **Sync Policy:**
> Choose `Automatic`.

> 3. In the `Source` section:
> - **Repo URL:**
> Add the Git repository URL that contains your Kubernetes manifests.
> - **Path:** 
 `Kubernetes` (or the actual path inside the repo where your manifests reside)

> 4. In the “Destination” section:
>  -  **Cluster URL:**
 https://kubernetes.default.svc (usually shown as "default")
>  -    **Namespace:**
 default (or your desired namespace)

> 5. Click on “Create”.

<img width="1233" height="687" alt="argocd" src="https://github.com/user-attachments/assets/10a7096e-b314-4442-abc4-ec910a415182" />

### **Phase 5: Monitoring (Prometheus & Grafana)**

Step 1 – Add the Repository
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```
Step 2 – Update Helm Repo
```bash
helm repo update
```
This downloads chart index.

Step 3 – Now Install
```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```
Port Forward Method & Access Prometheus:
 ```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
```

`http://<your-server-ip>:9090`

 Port Forward Method & Access Grafana:
 ```bash
kubectl port-forward svc/kube-prometheus-grafana -n monitoring 3000:80
```

`http://<your-server-ip>:3000`

**Import a Dashboard:**

To make it easier to view metrics, you can import a pre-configured dashboard. Follow these steps:

- Click on the "+" (plus) icon in the left sidebar to open the "Create" menu.
- Select "Dashboard."
- Click on the "Import" dashboard option.
- Enter the dashboard code you want to import (e.g., code 17375 ).
- Click the "Load" button.
- Select the data source you added (Prometheus) from the dropdown.
- Click on the "Import" button.

<img width="1281" height="712" alt="grafana" src="https://github.com/user-attachments/assets/ca0a45fe-39a9-445c-930f-f08e5c165f79" />

### **Phase 6: Cleanup Infrastructure**

Destroy the resources in one go using Terraform
 ```bash
terraform destroy -auto-approve 
```
👩‍💻 Author
Mohammed Amir

