stages:
  - build
  - test
  - dependencycheck
  - security
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""

default:
  image: docker:latest
  services:
    - docker:dind

build-job:
  stage: build
  script:
    - echo "Building application..."
    - docker build -t my-app .
    - mkdir -p build-output
    - echo "Build artifacts stored" > build-output/build.log
  artifacts:
    paths:
      - build-output/

dependencycheck-job:
  stage: dependencycheck
  image: owasp/dependency-check
  before_script:
    - mkdir -p dependency-check-report
  script:
    - echo "Running OWASP Dependency-Check..."
    - /usr/share/dependency-check/bin/dependency-check.sh \
      --project "$CI_PROJECT_NAME" \
      --scan "/builds/$CI_PROJECT_NAMESPACE/$CI_PROJECT_NAME" \
      --out dependency-check-report \
      --format ALL \
      --failOnCVSS 7
  artifacts:
    paths:
      - dependency-check-report/

deploy-job:
  stage: deploy
  environment: production
  script:
    - echo "Deploying application..."
    - echo "Application successfully deployed."
  artifacts:
    paths:
      - deployment-logs/
