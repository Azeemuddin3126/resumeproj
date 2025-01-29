#!/bin/bash

echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "Installing required dependencies..."
sudo apt install -y fontconfig openjdk-21-jre curl wget apt-transport-https

echo "Adding Jenkins repository key..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "Adding Jenkins repository..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Updating package list..."
sudo apt update -y

echo "Installing Jenkins..."
sudo apt install -y jenkins

echo "Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "Checking Jenkins status..."
sudo systemctl status jenkins --no-pager

echo "Allowing Jenkins through the firewall (port 8080)..."
sudo ufw allow 8080
sudo ufw reload

echo "Retrieving initial Jenkins admin password..."
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "Jenkins installation complete! 🎉"
echo "Access Jenkins at: http://your-server-ip:8080"


# chmod +x install_jenkins.sh
# ./install_jenkins.sh
