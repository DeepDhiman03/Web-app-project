pipeline {
    agent any
    environment {
        S3_BUCKET = 'static-webapp-bucket'
    }
    stages {
        stage('Clone Repositories') {
            parallel {
                stage('Clone Backend') {
                    steps {
                        dir('backend') {
                            git branch: 'main', url: 'https://github.com/DeepDhiman03/backend.git'
                        }
                    }
                }
                stage('Clone Frontend') {
                    steps {
                        dir('frontend') {
                            git branch: 'main', url: 'https://github.com/DeepDhiman03/frontend.git'
                        }
                    }
                }
            }
        }
        stage('Backend Deployment') {
            steps {
                dir('backend') {
                    sh 'docker build -t deepdhiman/backend:latest .'
                    withCredentials([usernamePassword(credentialsId: 'dockerHubCred', 
                    passwordVariable: 'dockerHubPass', 
                    usernameVariable: 'dockerHubUser')]) {
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPass}"
                    sh "docker push ${env.dockerHubUser}/backend:latest"
                    sh "docker-compose down && docker-compose up -d"
                    }
                    
                    
                }
            }
        }
        stage('Frontend Deployment') {
            steps {
                dir('frontend') {
                    withAWS(region: 'us-east-1', credentials: 'AWS_CREDENTIALS_ID') { 
                    sh 'aws s3 sync . s3://${S3_BUCKET} --delete'
                    }
                }
            }
        }
    }
}
