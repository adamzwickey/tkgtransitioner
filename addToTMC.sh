#! /bin/bash
set -x

export KUBECONFIG=$1-kubeconfig
kubectl config use-context $1-admin@$1

export KUBECONFIG=$1-kubeconfig
kubectl get nodes
echo TMC_API_TOKEN=$TMC_API_TOKEN
echo TMC_GROUP=$TMC_GROUP
./tmc login --no-configure --name temp
./tmc cluster attach -g $TMC_GROUP -n $1 -o manifest.yaml --management-cluster-name attached --provisioner-name attached
kubectl apply -f manifest.yaml