kubectl run nginx --image=nginx

kubectl create -f deployment.yaml

kubectl apply -f deployment.yaml

kubectl edit deployment nginx-deployment

kubectl replace -f deployment.yaml

kubectl patch deployment nginx-deployment -p '{"spec":{"replicas":3}}'

kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml

kubectl create service clusterip my-service --tcp=80:80 --dry-run=client -o yaml > service.yaml

kubectl create ingress nginx-ingress \
  --rule="example.com/*=my-service:80" \
  --dry-run=client -o yaml > nginx-ingress.yaml

