
# login the azure AKS
az aks get-credentials --resource-group LoadBalancing --name humblepig-mktsvc-k8s-cluster

# create the namespace
kubectl create ns mktsvc

# deployment
kubectl apply -f deployment.yaml

# get pods
kubectl get pods -n mktsvc 

# Example of bundling to a subscription
$ export ARM_SUBSCRIPTION_ID=159f2485-xxxx-xxxx-xxxx-xxxxxxxxxxxx
$ export ARM_TENANT_ID=72f988bf-xxxx-xxxx-xxxx-xxxxxxxxxxxx