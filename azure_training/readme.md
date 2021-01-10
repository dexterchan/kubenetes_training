
# login the azure AKS
az aks get-credentials --resource-group LoadBalancing --name humblepig-mktsvc-k8s-cluster

# create the namespace
kubectl create ns mktsvc

# deployment
kubectl apply -f deployment.yaml

# get pods
kubectl get pods -n mktsvc 