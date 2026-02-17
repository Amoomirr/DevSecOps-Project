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