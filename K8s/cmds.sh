kubectl run name -n nsname --image salmaan21/status:v2 --dry-run -o yaml

kubectl api-resources
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=true -o wide
kubectl get all --all-namespaces

kubectl expose pod alpha1 --port=8000 --target-port=80 --type=NodePort

kubectl describe svc alpha1

kubectl create ns alpha
kubectl create ns bravo

kubectl run alpha1 -n alpha --image=kiran2361993/kubegame:v1 --dry-run=client -o yaml

kubectl api-resources

kubectl api-resources --namespaced=true

# explain resource
kubectl explain pod
kubectl explain pod.spec.affinity
kubectl describe svc alpha1