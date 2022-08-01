#!/bin/sh

terraform init
terraform apply

mkdir -p .env

terraform output azure_eus_cert >.env/azure_cert
terraform output azure_eus_cnf >.env/kube-public

# expected to be configured to minikube
kubectl config view >.env/kube-private
