#!/bin/bash
####################################################
# Interactive setup script
# ------------------------
# Author: Simon Anliker
# Description: Interactive script to guide through
#   the envrionment setup needed to run hybrid
#   continuous deployments that were developed
#   as part of this thesis. Please refer to the
#   user manual at docs/manual.md
# Usage: . ./setup.sh
####################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
AT="$YELLOW\u0021$NC" # yellow exlamation mark
NOK="$RED\u0078$NC"   # red latin small letter x
OK="$GREEN\u2713$NC"  # green check mark

chmod +x bsc-env/apps/apply.sh
chmod +x bsc-env/infra/install.sh
chmod +x bsc-env/infra/uninstall.sh
chmod +x bin/bsc-deployer
chmod +x bin/legacyctld
chmod +x bin/legacyctl

startLegacyctld() {
  ./bin/legacyctld >./bin/legacyctld.log 2>&1 &
  echo "Process started with PID $!"
}

logLegacyctld() {
  tail -n500 -f ./bin/legacyctld.log
}

stopLegacyctld() {
  kill "$(pgrep legacyctld)"
  echo "Done"
}

startDeployer() {
  ./bin/bsc-deployer >./bin/bsc-deployer.log 2>&1 &
  echo "Process started with PID $!"
}

logDeployer() {
  tail -n500 -f ./bin/bsc-deployer.log
}

stopDeployer() {
  kill "$(pgrep bsc-deployer)"
  echo "Done"
}

startArtifactory() {
  cd bsc-artifactory || exit
  ./artifactory.sh start >./../bin/artifactory.log 2>&1 &
  echo "Process started with PID $!"
  cd .. || exit
}

logArtifactory() {
  tail -n500 -f ./bin/artifactory.log
}

stopArtifactory() {
  ./bsc-artifactory/artifactory.sh stop
  echo "Done"
}

setupGitHooks() {
  echo "Install git client-side hook for deployments"
  cp -f bsc-deployer/client.sh .git/modules/bsc-env/hooks/post-commit
  echo "Installed:"
  find .git/modules/bsc-env/hooks/* -not -name "*.sample"
}

prepareKubeConfig() {
  env_path=$(pwd)/bsc-env/infra/.env
  config_public="$env_path/kube-public"
  config_private="$env_path/kube-private"
  echo "Using public cloud config: $config_public"
  echo "Using private cloud config: $config_private"
  export KUBECONFIG="$KUBECONFIG:$config_public:$config_private"

  echo
  conf=$(kubectl config view)
  validateKubeConfig "$conf" "minikube"
  validateKubeConfig "$conf" "bsc-aks"
}

validateKubeConfig() {
  if [[ "$1" == *"$2"* ]]; then
    echo -e "$2 is configured $OK"
  else
    echo -e "$2 is not configured $NOK"
  fi
}

showKubeConfig() {
  kubectl config view
}

exitWithErr() {
  echo -e "$1"
  exit 1
}

require() {
  if [ -z "$1" ]; then
    exitWithErr "$2 is not set $NOK"
  else
    echo -e "$2 is set $OK"
  fi
}

setupPrivateCloud() {
  echo -e "This step requires manual intervention. $AT"
  echo "For more information visit the private cloud section of the user manual."
  echo
  ec=1
  while true; do
    if [ "$ec" -eq 0 ]; then
      break
    fi
    echo "Checks:"
    # exit code represents minikube state
    minikube status
    ec=$?
    echo
    if [ $ec == 7 ]; then
      # 7 means all down
      echo "Starting minikube."
      minikube start

    elif [ $ec == 0 ]; then
      # 0 means running
      echo -e "Minikube is running. $OK"

    else
      # else it's probably not installed
      echo "Please follow the manual on how to setup minikube."
      read -n 1 -s -r -p "If done, press any key to continue."
      echo -e "\n"
    fi
  done
}

# shellcheck disable=SC2154
# ^ using env variables
checkPublicCloudPrerequisites() {
  echo -e "This step requires manual intervention. $AT"
  echo "For more information visit the public cloud section of the user manual."
  echo
  echo "Checks:"
  require "${TF_VAR_arm_subscription_id+x}" "TF_VAR_arm_subscription_id"
  require "${TF_VAR_arm_tenant_id+x}" "TF_VAR_arm_tenant_id"
  require "${TF_VAR_arm_client_id+x}" "TF_VAR_arm_client_id"
  require "${TF_VAR_arm_client_secret+x}" "TF_VAR_arm_client_secret"
  echo
  read -n 1 -s -r -p "Checks passed. Press any key to continue."
  echo -e "\n"
}

setupPublicCloud() {
  checkPublicCloudPrerequisites
  current_dir=$(pwd)
  cd ./bsc-env/infra || exit
  ./install.sh
  cd "$current_dir" || exit
}

tearDownPublicCloud() {
  checkPublicCloudPrerequisites
  current_dir=$(pwd)
  cd ./bsc-env/infra || exit
  ./uninstall.sh
  cd "$current_dir" || exit
}

cmd() {
  echo "\----------------------------"
  "$@"
  echo "/----------------------------"
}

# options
Ckubeconf_back="Backup current kube config"
Chooks="Install git hooks"
Cpubcloud="Setup public cloud environment"
Cprivcloud="Setup private cloud environment"
Ckubeconf="Prepare kube config"
Ckubeconf_show="Show kube config"
Clegacyctld_start="Start legacyctld server"
Clegacyctld_stop="Stop legacyctld server"
Clegacyctld_log="Tail legacyctld logs"
Cdeployer_start="Start deployer server"
Cdeployer_stop="Stop deployer server"
Cdeployer_log="Tail deployer logs"
Cartifactory_start="Start artifactory server"
Cartifactory_stop="Stop artifactory server"
Cartifactory_log="Tail artifactory logs"
Cpubcloud_del="Destroy public cloud environment"
Ckubeconf_reset="Restore kube config"
Cx="Exit"

# move lines to change order / number
index=(
  # set up
  "$Chooks"
  "$Cprivcloud"
  "$Cpubcloud"
  "$Ckubeconf"
  "$Cartifactory_start"
  "$Clegacyctld_start"
  "$Cdeployer_start"
  # operations
  "$Ckubeconf_show"
  "$Cartifactory_log"
  "$Clegacyctld_log"
  "$Cdeployer_log"
  #  tear down
  "$Cpubcloud_del"
  "$Ckubeconf_reset"
  "$Cartifactory_stop"
  "$Clegacyctld_stop"
  "$Cdeployer_stop"
  # exit comes last
  "$Cx"
)

W="\u8FCE" # welcome cjk
J="\u9014" # journey cjk
W_LINE="$YELLOW$W$W$W$W$W$W$W$W$W$W$W$W$W$W$W$W$W$NC"
echo -e "$W_LINE\nWelcome to the interactive setup.\nPlease use this in combination with the user manual.\nEvery step will perform certain checks, execute scripts and may export variables.\n$W_LINE"
done=0
while true; do
  if [ "$done" -ne 0 ]; then
    break
  fi
  echo "Which step should I execute:"
  select yn in "${index[@]}"; do
    case $yn in
    $Ckubeconf_back)
      export KUBECONFIG_SAVED=$KUBECONFIG
      break
      ;;
    $Clegacyctld_start)
      cmd startLegacyctld
      break
      ;;
    $Cdeployer_start)
      cmd startDeployer
      break
      ;;
    $Cartifactory_start)
      cmd startArtifactory
      break
      ;;
    $Cartifactory_stop)
      cmd stopArtifactory
      break
      ;;
    $Clegacyctld_stop)
      cmd stopLegacyctld
      break
      ;;
    $Cdeployer_stop)
      cmd stopDeployer
      break
      ;;
    $Cartifactory_log)
      cmd logArtifactory
      break
      ;;
    $Clegacyctld_log)
      cmd logLegacyctld
      break
      ;;
    $Cdeployer_log)
      cmd logDeployer
      break
      ;;
    $Chooks)
      cmd setupGitHooks
      break
      ;;
    $Cpubcloud)
      cmd setupPublicCloud
      break
      ;;
    $Cprivcloud)
      cmd setupPrivateCloud
      break
      ;;
    $Ckubeconf)
      cmd prepareKubeConfig
      break
      ;;
    $Ckubeconf_show)
      cmd showKubeConfig
      break
      ;;
    $Cpubcloud_del)
      cmd tearDownPublicCloud
      break
      ;;
    $Ckubeconf_reset)
      export KUBECONFIG=$KUBECONFIG_SAVED
      break
      ;;
    $Cx)
      echo -e "$YELLOW$J$NC"
      done=1
      break
      ;;
    esac
  done
done
