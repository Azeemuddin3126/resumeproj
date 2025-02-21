#!/bin/bash

# Continuously monitor the deployment and forward ports
while true; do
  # Get the latest pod from the rolling deployment
  POD_NAME=$(kubectl get pods -l app=rolling-app -o jsonpath='{.items[0].metadata.name}')
  
  # Forward the port to the current pod
  kubectl port-forward pod/$POD_NAME 8282:80 &
  
  # Wait for the port-forward process to finish
  wait $!
  
  # Sleep briefly before checking againku
  sleep 1
done
