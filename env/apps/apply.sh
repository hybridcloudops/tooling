#!/bin/bash
####################################################
# DISCONTINUED
# first version of the deployer workflow
####################################################

# change to empty string to disable coloring
color=yes

# use for deploy:
#git log --pretty=format:'%h %s' --abbrev-commit -1

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

# assuming private 2, public 1, legacy 0
# label queries
deploy_to_private="cloud-private==supported"
deploy_to_public="cloud-private!=supported,cloud-public==supported"
not_on_cloud="cloud-private!=supported,cloud-public!=supported"
#deploy_legacy="$not_on_cloud,legacy=supported"

# all private cloud capable services
print "\nInstalling private cloud services"
print "======================================"
print "\nSwitch to private cloud environment:"
set_dark_gray
kubectl config use-context minikube
kubectl version --short
printnc "\nApply supported services:"
set_dark_gray
kubectl apply -f . -R -l $deploy_to_private
printnc "\nDelete unsupported services:"
set_dark_gray
kubectl delete -f . -R -l $deploy_to_public
kubectl delete -f . -R -l $not_on_cloud

# remaining public cloud capable services
printnc "\nInstalling public cloud services"
print "======================================"
print "\nSwitch to public cloud environment:"
set_dark_gray
kubectl config use-context bsc-aks
kubectl version --short
printnc "\nApply supported services:"
set_dark_gray
kubectl apply -f . -R -l $deploy_to_public
printnc "\nDelete unsupported services:"
set_dark_gray
kubectl delete -f . -R -l $deploy_to_private
kubectl delete -f . -R -l $not_on_cloud

# switch back to minikube to not accidentally deploy to azure
printnc "\nSwitch to private cloud environment:"
set_dark_gray
kubectl config use-context minikube

# remaining legacy services
printnc "\nInstalling legacy services"
print "======================================"
print "Nothing to do"
