#!/bin/sh
# Create an Azure resource group
export ResourceGroup=AKS_DEMO
export ClusterName=ClusterDemo
az group create --name ${ResourceGroup} --location westus2

#Create cluster only
az aks create -g ${ResourceGroup} -n $ClusterName --enable-managed-identity
az aks create -g ${ResourceGroup} -n $ClusterName --enable-managed-identity --ssh-key-values ~/.ssh/aws_humble_pig.pub 

# Create an AKS cluster with ACR integration
az aks create -n $ClusterName -g ${ResourceGroup} --generate-ssh-keys --attach-acr $MYACR

#Attach registry to existing cluster
az aks update -n $ClusterName -g ${ResourceGroup} --attach-acr <acr-name>

#Use the following command to query objectid of your control plane managed identity:
az aks show -g ${ResourceGroup} -n $ClusterName  --query "identity"
export appId=$(az aks show -g ${ResourceGroup} -n $ClusterName  --query "identity" | jq -r ".principalId")
export RESOURCE_SCOPE=/subscriptions/c01378bd-5b91-4df3-8da6-420d0b751d46/resourceGroups/AKS_DEMO
az role assignment create --assignee $appId --scope $RESOURCE_SCOPE --role Contributor

az aks get-credentials --resource-group ${ResourceGroup}  --name $ClusterName

az aks delete --name $ClusterName --resource-group ${ResourceGroup} 