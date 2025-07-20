pipeline {
    agent any

    environment {
        IMAGE_NAME = "dilipkamti/discovery_service"
        DOCKER_TAG_PREFIX = "v"
    }

    parameters {
        booleanParam(name: 'DELETE_OLD_BUILDS', defaultValue: false, description: 'Delete old Docker containers/images before building?')
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/DilipKamti/discovery_service.git'
            }
        }

        stage('Determine Docker Image Version') {
            steps {
                script {
                    def versionFile = '.docker-version'
                    def currentVersion = '0.0'
                    if (fileExists(versionFile)) {
                        currentVersion = readFile(versionFile).trim()
                    }
                    def (major, minor) = currentVersion.tokenize('.').collect { it.toInteger() }
                    def newVersion = "${major}.${minor + 1}"
                    def versionTag = "${DOCKER_TAG_PREFIX}${newVersion}"
                    env.DOCKER_VERSION = versionTag
                    writeFile file: versionFile, text: newVersion
                }
            }
        }

        stage('Clean Old Docker Resources') {
            when {
                expression { params.DELETE_OLD_BUILDS }
            }
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            docker ps -a --filter "ancestor=dilipkamti/discovery_service" --format "{{.ID}}" | xargs -r docker stop || true
                            docker ps -a --filter "ancestor=dilipkamti/discovery_service" --format "{{.ID}}" | xargs -r docker rm || true
                            docker images dilipkamti/discovery_service --format "{{.Repository}}:{{.Tag}}" | grep -v ${DOCKER_VERSION} | xargs -r docker rmi -f || true
                        '''
                    } else {
                        bat """
                        for /f "delims=" %%i in ('docker ps -a --filter "ancestor=dilipkamti/discovery_service" --format "{{.ID}}"') do (
                            docker stop %%i
                            docker rm %%i
                        )

                        powershell -Command "docker images dilipkamti/discovery_service --format '{{.Repository}}:{{.Tag}}' | Where-Object { \$_ -ne '${IMAGE_NAME}:${DOCKER_VERSION}' } | ForEach-Object { docker rmi -f \$_ }"
                        """
                    }
                }
            }
        }

        stage('Build Maven Project') {
            steps {
                script {
                    def mvnCmd = "mvn clean package -DskipTests"
                    if (isUnix()) {
                        sh mvnCmd
                    } else {
                        bat mvnCmd
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def versionTag = "${IMAGE_NAME}:${DOCKER_VERSION}"
                    def buildCmd = "docker build -t ${versionTag} ."
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
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    script {
                        if (isUnix()) {
                            sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                        } else {
                            bat "echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin"
                        }
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def versionTag = "${IMAGE_NAME}:${DOCKER_VERSION}"
                    if (isUnix()) {
                        sh "docker push ${versionTag}"
                    } else {
                        bat "docker push ${versionTag}"
                    }
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                echo "Deploying discovery_service with Docker tag: ${DOCKER_VERSION}"
                // Add your deployment logic here (docker-compose, kubectl, etc.)
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "✅ discovery_service build and deployment successful with Docker tag: ${DOCKER_VERSION}"
        }
        failure {
            echo "❌ discovery_service build or deployment failed!"
        }
    }
}
