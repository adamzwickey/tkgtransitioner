#! /bin/bash

echo Workload kubeconfig:
cat $1-kubeconfig

export KUBECONFIG=$1-kubeconfig
kubectl config use-context $1-admin@$1
kubectl create ns argocd
kubectl create serviceaccount argocd -n argocd
kubectl create clusterrolebinding argocd --clusterrole=cluster-admin --serviceaccount=argocd:argocd
export TOKEN_SECRET=$(kubectl get serviceaccount -n argocd argocd -o jsonpath='{.secrets[0].name}')
export TOKEN=$(kubectl get secret -n argocd $TOKEN_SECRET -o jsonpath='{.data.token}' | base64 --decode)
kubectl config set-credentials $1-argocd-token-user --token $TOKEN
kubectl config set-context $1-argocd-token-user@$1 \
  --user $1-argocd-token-user \
  --cluster $1
# Add the config setup with the service account
argocd login $2 \
  --username admin \
  --password $3 \
  --insecure  # Need this as we don't have a signed cert yet
argocd cluster add $1-argocd-token-user@$1

SERVER=$(argocd cluster list | grep $1-argocd-token-user@$1 | awk '{print $1}')
echo Adding to mgmt server: $MGMT_SERVER
echo Helm dest server: $SERVER
argocd app create $1-app-of-apps \
  --repo https://gitlab.com/azwickey/tkg-autopilot.git \
  --dest-server $4 \
  --dest-namespace default \
  --sync-policy automated \
  --path cd/argo/workload1 \
  --helm-set server=$SERVER