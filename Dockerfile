FROM ubuntu:16.04

RUN apt-get update && apt-get install -y jq curl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin
RUN curl -LO https://github.com/argoproj/argo-cd/releases/download/v1.7.7/argocd-linux-amd64 && chmod u+x argocd-linux-amd64 &&  chmod o+x argocd-linux-amd64 && mv argocd-linux-amd64 /usr/local/bin/argocd

COPY transition.sh .
COPY addToArgo.sh .
COPY addToTMC.sh .
COPY tmc .

ARG clustername
ARG argoUrl
ARG argoPwd
ARG mgmtCluster
ARG gitOpsPath

ENTRYPOINT ["./transition.sh"]
