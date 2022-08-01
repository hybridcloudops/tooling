#!/bin/bash
####################################################
# DISCONTINUED
# first version of the deployer workflow
####################################################

# change to empty string to disable coloring
color=yes

function set_dark_gray() {
  if [ $color ]; then
    # color code for dark gray
    printf "\033[1;30m"
  fi
}

function set_no_color() {
  if [ $color ]; then
    # color code for no color
    printf "\033[0m"
  fi
}

function printnc() {
  set_no_color
  print "$1"
}

function print() {
  echo -e "$1"
}

# all private cloud capable services
print "\nInstalling private cloud services"
print "======================================"
print "\nSwitch to private cloud environment:"
set_dark_gray
kubectl config use-context minikube
kubectl version --short
printnc "\nApply supported services:"
set_dark_gray
kubectl apply -f policy-crd.yaml

# get all namespaces where cpols are configured
namespaces=$(kubectl get cpol -A -o jsonpath='{.items[*].metadata.namespace}')
for ns in $namespaces; do

    # get all policies for a namespace
    policies=$(kubectl get cpol -o jsonpath='{.items[*].metadata.name}' --namespace="$ns")

    # delete policies for namespace
    for pol in $policies; do
      kubectl delete cpol "$pol" --namespace="$ns"
    done
done

# apply new policies
kubectl apply -f definitions/policy-private.yaml --namespace=default
kubectl apply -f definitions/policy-public.yaml --namespace=vote
kubectl apply -f definitions/policy-private.yaml --namespace=monitoring
kubectl apply -f definitions/policy-private-or-public.yaml --namespace=rest
kubectl apply -f definitions/policy-private-and-public.yaml --namespace=rest-ha


print "\nPolicy setup"
print "======================================"
kubectl get cpol -A

