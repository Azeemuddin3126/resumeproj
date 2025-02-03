// dckr_pat_MB5nBsvW9GPg5q3v5yug3oxxmZE
// squ_4e5a45eb7de61351d16869204a4e978001904851
pipeline {
    agent any

    environment {
        GITHUB_REPO = 'https://github.com/Azeemuddin3126/Django-sample-web.git'
        BRANCH = 'main'
        IMAGE = 'python:3.9-slim'  // Python base image for Docker
        DOCKER_IMAGE_BASE = 'salmaan21/django-sample-web'
        SONARQUBE_SCANNER_HOME = tool 'sonarscan'
        SONARQUBE_URL = 'http://localhost:9000'
        SLACK_CHANNEL = '#devopsworkupdates'
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
                echo "Cloning the repository..."
                git branch: "${BRANCH}", url: "${GITHUB_REPO}"
            }
        }

        stage('Static Code Analysis (Flake8)') {
            steps {
                echo "Running static code analysis with Flake8..."
                sh """
                    docker run --rm -v \$(pwd):/apps alpine/flake8 /apps > flake8-report.txt || echo "Done testing, please check the file"
                """
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo "Running unit tests..."
                sh """
                    docker run --rm python:3.9-alpine sh -c "pip install pytest && pytest --maxfail=5 --disable-warnings --verbose > result.txt || tail -n 10 result.txt"
                """
            }
        }

        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan . ', odcInstallation: 'dp'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('TRIVY FS SCAN') {
            steps {
                sh "docker run --rm aquasec/trivy fs . > trivy-fs-report.txt"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube Analysis...'
                withSonarQubeEnv('sonarqube') {
                    sh "sonar-scanner -Dsonar.sources=. -Dsonar.projectName=SampleApp -Dsonar.projectKey=SampleApp"
                }
            }   
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def dockerImageTag = "${DOCKER_IMAGE_BASE}:${BUILD_NUMBER}"
                    docker.withRegistry('', 'docker') {
                        def image = docker.build(dockerImageTag)
                        image.push()
                        image.push('latest')
                    }
                    env.DOCKER_IMAGE_NAME = dockerImageTag
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                echo 'Running Trivy Image Scan...'
                sh """
                    docker run --rm aquasec/trivy image ${DOCKER_IMAGE_NAME} --scanners vuln > trivy-image-report.txt
                """
            }
        }

        stage('Clean up the system') {
            steps {
                echo 'Cleaning up the docker system...'
                sh """
                    docker system prune -a --force
                """
                echo 'Done pruning...'
            }
        }
    }

    post {
        always {
            emailext attachLog: true,
                subject: "'${currentBuild.result}'",
                body: "Project: ${env.JOB_NAME}<br/>" +
                      "Build Number: ${env.BUILD_NUMBER}<br/>" +
                      "URL: ${env.BUILD_URL}<br/>",
                to: 'salmaan2631@gmail.com',
                attachmentsPattern: '*.txt'
        }
        success {
            echo "Build and scans completed successfully."
            slackSend(
                channel: "${SLACK_CHANNEL}", 
                message: "Build and scans completed successfully.\nBuild URL: ${env.BUILD_URL}"
            )
        }
        failure {
            echo "Build or scan failed. Please check the logs."
            slackSend(
                channel: "${SLACK_CHANNEL}", 
                message: "Build or scan failed. Please check the logs.\nBuild URL: ${env.BUILD_URL}"
            )
        }
    }
}
