#!/bin/bash

echo 'Creating a K8s Deployment YAML file......'
sleep 1

# Input parameters
read -p "Enter a Deployment Name (e.g., portfolio): " dn
read -p "Enter an Image Name: " in
read -p "Enter Number of Replicas: " repn
read -p "Enter a File Name: " fn
read -p "Enter a Port Type (e.g., NodePort): " pt
read -p "Enter a Target Port Number (e.g., 8000 for Django apps): " tp
read -p "Enter maxSurge value (e.g., 25%, 1, etc.): " maxs
read -p "Enter maxUnavailable value (e.g., 25%, 1, etc.): " maxu

# Create deployment YAML with basic configuration
kubectl create deployment "$dn" --image="$in" --replicas="$repn" --dry-run=client -o yaml > "$fn.yaml"

# Apply deployment YAML
echo "Applying Deployment YAML..."
kubectl apply -f "$fn.yaml"
sleep 1

# Patch the deployment to add rolling update strategy with user inputs
echo "Patching Deployment with Rolling Update Strategy..."
kubectl patch deployment "$dn" -p "{\"spec\":{\"strategy\":{\"type\":\"RollingUpdate\",\"rollingUpdate\":{\"maxSurge\":\"$maxs\",\"maxUnavailable\":\"$maxu\"}}}}"

# Create and apply service configuration
echo "Creating Service..."
kubectl expose deployment "$dn" --type="$pt" --port=80 --target-port="$tp" --dry-run=client -o yaml >> "$fn.yaml"
echo "Applying Service YAML..."
kubectl apply -f "$fn.yaml"
sleep 5

# Wait for Pod Readiness
echo "Waiting for pod to become ready..."
kubectl wait --for=condition=ready pod -l app="$dn" --timeout=60s

# Check if pods are running
if ! kubectl get pods -l app="$dn" | grep -q 'Running'; then
  echo "Error: Pods are not running. Check deployment or image configuration."
  exit 1
fi

# Display resources
kubectl get all

# Port forwarding
echo "Deployment Successful..."
echo "Starting Port Forwarding..."
echo "Deployed Successfully. Access the app at http://localhost:$tp"

kubectl port-forward service/"$dn" "$tp":80 &
