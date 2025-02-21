#!/bin/bash

# Continuously monitor the service and forward ports
while true; do
  # Forward the port to the service
  kubectl port-forward svc/rolling-service 8282:80 &
  
  # Wait for the port-forward process to finish
  wait $!
  
  # Sleep briefly before retrying the port-forward
  sleep 1
done
