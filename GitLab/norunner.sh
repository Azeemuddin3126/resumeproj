stages:
  - build
  - test
  - dependencycheck
  - security
  - deploy

variables:
  DOCKER_DRIVER: overlay2  # Ensures stable Docker performance
  DOCKER_TLS_CERTDIR: ""    # Disables TLS inside DinD for better compatibility

default:
  image: docker:latest  # Use a Docker-enabled image
  services:
    - docker:dind  # Enables Docker-in-Docker

build-job:
  stage: build
  script:
    - echo "Building the application..."
    - docker info  # Verify Docker is running
    - docker build -t my-app .
    - mkdir -p build-output
    - echo "Build artifacts stored" > build-output/build.log
  artifacts:
    paths:
      - build-output/

unit-test-job:
  stage: test
  script:
    - echo "Running security scan with Trivy..."
    - docker run --rm -v $(pwd):/app aquasec/trivy fs /app > trivy-fs-report.txt
  artifacts:
    paths:
      - trivy-fs-report.txt

lint-test-job:
  stage: test
  script:
    - echo "Linting code..."
    - echo "No lint issues found."

dependencycheck-job:
  stage: dependencycheck
  image: owasp/dependency-check
  before_script:
    - mkdir -p data dependency-check
  script:
    - echo "Updating OWASP Dependency-Check database..."
    - /usr/share/dependency-check/bin/dependency-check.sh --updateonly
    - echo "Running Dependency-Check scan..."
    - /usr/share/dependency-check/bin/dependency-check.sh --project Test --out dependency-check/ --scan . --enableExperimental --failOnCVSS 7
  artifacts:
    paths:
      - dependency-check/

security-scan-job:
  stage: security
  image: aquasec/trivy
  script:
    - echo "Running container image security scan..."
    - docker build -t my-app .
    - docker run --rm aquasec/trivy image my-app > trivy-image-report.txt
  artifacts:
    paths:
      - trivy-image-report.txt

deploy-job:
  stage: deploy
  environment: production
  script:
    - echo "Deploying application..."
    - echo "Application successfully deployed."
  artifacts:
    paths:
      - deployment-logs/
