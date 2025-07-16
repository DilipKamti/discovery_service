pipeline {
    agent any

    environment {
        IMAGE_NAME = "dilipkamti/discovery_service"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/DilipKamti/discovery_service.git'
            }
        }

        stage('Build') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'mvn clean package -DskipTests'
                    } else {
                        bat 'mvn clean package -DskipTests'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def buildCmd = "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    if (isUnix()) {
                        sh buildCmd
                    } else {
                        bat buildCmd
                    }
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        def loginCmd = "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                        if (isUnix()) {
                            sh loginCmd
                        } else {
                            bat """echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin"""
                        }
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def pushCmd = "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    if (isUnix()) {
                        sh pushCmd
                    } else {
                        bat pushCmd
                    }
                }
            }
        }
    }
}
