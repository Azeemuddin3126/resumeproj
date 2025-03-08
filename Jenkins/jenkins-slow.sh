#!/bin/bash

# Variables
JENKINS_CONFIG="/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml"
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Update Jenkins URL in the config file
sed -i "s#<url>.*</url>#<url>http://$PUBLIC_IP:8080/</url>#" $JENKINS_CONFIG

# Restart Jenkins to apply the changes
systemctl restart jenkins
