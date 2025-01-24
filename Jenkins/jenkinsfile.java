pipeline {
    agent {
        docker {
            image 'maven:3.8.5-jdk-11'  // Use Maven with JDK 11 for building the Java app
            args '-v /var/run/docker.sock:/var/run/docker.sock'  // Mount Docker socket for Docker-in-Docker operations
        }
    }

    environment {
        REPO_URL = 'https://github.com/your-username/sample-java-web-app.git'
        DOCKER_IMAGE_NAME = 'yourdockerhub/javaapp'  // Base image name
        DOCKER_CRED = credentials('docker-hub-credentials')
        TRIVY_IMAGE = 'aquasec/trivy:latest'
        SONARQUBE_SERVER = 'SonarQube'
        TOMCAT_URL = 'http://your-tomcat-server:8080/manager/text'
        TOMCAT_CRED = credentials('tomcat-credentials')
        SLACK_CHANNEL = '#build-notifications'
        TAG = "v1.${BUILD_NUMBER}"  // Dynamically generate version based on Jenkins build number (v1.x format)
        SONAR_TOKEN = credentials('sonarqube-token')
        DEPENDENCY_CHECK_TOOL = 'dc'  // Dependency Check tool name for OWASP scan
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()  // Clean workspace before starting the pipeline
            }
        }

        stage('Checkout Code') {
            steps {
                echo "Cloning the repository..."
                git branch: 'main', url: "${REPO_URL}"  // Checkout the latest code from the GitHub repository
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonarqube-token')
            }
            steps {
                echo "Running SonarQube analysis..."
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=java-web-app'  // Run SonarQube scan
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                echo "Checking SonarQube Quality Gate..."
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true  // Check the quality gate
                }
            }
        }

        stage('Build & Test with Maven') {
            steps {
                echo "Building the application..."
                sh 'mvn clean package'  // Build the application with Maven
                echo "Running unit tests..."
                sh 'mvn test'  // Run unit tests
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                echo "Running OWASP Dependency Check..."
                sh """
                    ${DEPENDENCY_CHECK_TOOL} --scan ./ --format json --out .dependency-check-report.json
                """
                archiveArtifacts artifacts: '.dependency-check-report.json', fingerprint: true  // Archive dependency check result
            }
        }

        stage('Docker Build and Push') {
            steps {
                script {
                    echo "Building Docker image with tag: ${TAG}..."
                    sh """
                        docker build -t ${DOCKER_IMAGE_NAME}:${TAG} .  // Build Docker image with dynamic tag
                        docker login -u ${DOCKER_CRED_USR} -p ${DOCKER_CRED_PSW}  // Log into Docker Hub
                        docker push ${DOCKER_IMAGE_NAME}:${TAG}  // Push the Docker image to Docker Hub
                    """
                    currentBuild.displayName = "#${BUILD_NUMBER} - ${TAG}"  // Display the build name in Jenkins UI
                }
            }
        }

        stage('Trivy Repo Scan') {
            steps {
                script {
                    echo "Running Trivy repository scan..."
                    sh """
                        docker run --rm ${TRIVY_IMAGE} repo ${REPO_URL} --format json > trivy-repo-scan.json
                    """
                    archiveArtifacts artifacts: 'trivy-repo-scan.json', fingerprint: true  // Archive the Trivy repo scan result
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    echo "Running Trivy scan on the Docker image..."
                    sh """
                        docker run --rm ${TRIVY_IMAGE} image ${DOCKER_IMAGE_NAME}:${TAG} --format json > trivy-image-scan.json
                    """
                    archiveArtifacts artifacts: 'trivy-image-scan.json', fingerprint: true  // Archive the Trivy scan result
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                script {
                    echo "Deploying the application to Tomcat..."
                    sh """
                        curl -u ${TOMCAT_CRED_USR}:${TOMCAT_CRED_PSW} \
                        -T target/*.war ${TOMCAT_URL}/deploy?path=/your-app-name&update=true
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Clean the workspace after each build
        }
        success {
            echo "Build, test, and deployment successful!"
            slackSend(channel: "${SLACK_CHANNEL}", message: "Build #${BUILD_NUMBER} for ${DOCKER_IMAGE_NAME}:${TAG} was successful!")
        }
        failure {
            echo "Build failed."
            slackSend(channel: "${SLACK_CHANNEL}", message: "Build #${BUILD_NUMBER} for ${DOCKER_IMAGE_NAME}:${TAG} failed!")
        }
    }
}
