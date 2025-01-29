#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update -y

# Install necessary dependencies
echo "Installing wget, curl, apt-transport-https..."
sudo apt install -y wget curl apt-transport-https

# Download JDK 21 (Temurin JRE)
echo "Downloading JDK 21 (Temurin JRE)..."
wget -q https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21+35/OpenJDK21U-jre_x64_linux_hotspot_21_35.tar.gz -O /tmp/temurin-jre.tar.gz

# Extract JDK to /opt directory
echo "Extracting JDK 21 to /opt..."
sudo tar -xvzf /tmp/temurin-jre.tar.gz -C /opt/

# Set environment variables
echo "Setting up JAVA_HOME and PATH..."
echo "export JAVA_HOME=/opt/jdk-21+35-jre" | sudo tee -a /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee -a /etc/profile

# Reload environment variables
source /etc/profile

# Verify installation
echo "Verifying Java installation..."
java -version

echo "Java 21 (Temurin JRE) installation complete!"



# chmod +x install_java21.sh
# ./install_java21.sh
