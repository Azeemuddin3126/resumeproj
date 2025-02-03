pipeline {
    agent any

    environment {
        MAVEN_IMAGE = 'maven:3.8.6-openjdk-11'  // Docker image with Maven and JDK 11
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo 'Cleaning workspace...'
                cleanWs()
            }
        }

        stage('Git Checkout') {
            steps {
                echo 'Cloning the repository...'
                git branch: 'main', url: 'https://github.com/yourusername/your-java-project.git'
            }
        }

        stage('Build with Maven') {
            steps {
                echo 'Building the project with Maven...'
                sh """
                    docker run --rm \
                        -v \$(pwd):/workspace \
                        -w /workspace \
                        ${MAVEN_IMAGE} \
                        mvn clean install
                """
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                sh """
                    docker run --rm \
                        -v \$(pwd):/workspace \
                        -w /workspace \
                        ${MAVEN_IMAGE} \
                        mvn test
                """
            }
        }

        stage('Package Artifact') {
            steps {
                echo 'Packaging the artifact (JAR)...'
                sh """
                    docker run --rm \
                        -v \$(pwd):/workspace \
                        -w /workspace \
                        ${MAVEN_IMAGE} \
                        mvn package
                """
            }
        }

        stage('Dockerize Java App') {
            steps {
                echo 'Building Docker image for the Java application...'
                script {
                    def dockerImageTag = "java-app:${BUILD_NUMBER}"
                    docker.build(dockerImageTag)
                    docker.withRegistry('', 'dockerhub') {
                        // Push the image to Docker Hub or any registry
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                    env.DOCKER_IMAGE_NAME = dockerImageTag
                }
            }
        }

    }
}
