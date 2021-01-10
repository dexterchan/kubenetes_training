#!/bin/sh
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
#Automate assumerole with aws cli
if [ ! -d ~/.aws ]; then
  mkdir ~/.aws
fi

cat << EoF >> ~/.aws/config
[profile admin]
role_arn=arn:aws:iam::${ACCOUNT_ID}:role/k8sAdmin
source_profile=eksAdmin

[profile dev]
role_arn=arn:aws:iam::${ACCOUNT_ID}:role/k8sDev
source_profile=eksDev

[profile integ]
role_arn=arn:aws:iam::${ACCOUNT_ID}:role/k8sInteg
source_profile=eksInteg

EoF

cat << EoF >> ~/.aws/credentials

[eksAdmin]
aws_access_key_id=$(jq -r .AccessKey.AccessKeyId /tmp/PaulAdmin.json)
aws_secret_access_key=$(jq -r .AccessKey.SecretAccessKey /tmp/PaulAdmin.json)

[eksDev]
aws_access_key_id=$(jq -r .AccessKey.AccessKeyId /tmp/JeanDev.json)
aws_secret_access_key=$(jq -r .AccessKey.SecretAccessKey /tmp/JeanDev.json)

[eksInteg]
aws_access_key_id=$(jq -r .AccessKey.AccessKeyId /tmp/PierreInteg.json)
aws_secret_access_key=$(jq -r .AccessKey.SecretAccessKey /tmp/PierreInteg.json)

EoF

#Using AWS profiles with the Kubectl config file
#Switch profile by ~/.kube/config 
#Use of environment variable $KUBECONFIG to inject the kube config
export KUBECONFIG=/tmp/kubeconfig-dev && eksctl utils write-kubeconfig eksworkshop-eksctl
cat $KUBECONFIG | yq w - -- 'users[*].user.exec.args[+]' '--profile' | yq w - -- 'users[*].user.exec.args[+]' 'dev' | sed 's/eksworkshop-eksctl./eksworkshop-eksctl-dev./g' | sponge $KUBECONFIG

kubectl run --generator=run-pod/v1 nginx-dev --image=nginx -n development
kubectl get pods -n development

#forbidden
kubectl get pods -n integration

#Test with integration profile
export KUBECONFIG=/tmp/kubeconfig-integ && eksctl utils write-kubeconfig eksworkshop-eksctl
cat $KUBECONFIG | yq w - -- 'users[*].user.exec.args[+]' '--profile' | yq w - -- 'users[*].user.exec.args[+]' 'integ' | sed 's/eksworkshop-eksctl./eksworkshop-eksctl-integ./g' | sponge $KUBECONFIG

#Test with admin
export KUBECONFIG=/tmp/kubeconfig-admin && eksctl utils write-kubeconfig eksworkshop-eksctl
cat $KUBECONFIG | yq w - -- 'users[*].user.exec.args[+]' '--profile' | yq w - -- 'users[*].user.exec.args[+]' 'admin' | sed 's/eksworkshop-eksctl./eksworkshop-eksctl-admin./g' | sponge $KUBECONFIG

#Switching between namespace
export KUBECONFIG=/tmp/kubeconfig-dev:/tmp/kubeconfig-integ:/tmp/kubeconfig-admin
#install kubectx
curl -sSLO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx && chmod 755 kubectx && sudo mv kubectx /usr/local/bin
