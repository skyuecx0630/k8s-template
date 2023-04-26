#!/bin/bash

# Determine k8s version and host architecture
KUBEVERSION=v1.25.0
ARCH=""
case $(uname -m) in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
esac

# Download kubectl
curl -LO "https://dl.k8s.io/release/$KUBEVERSION/bin/linux/$ARCH/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
echo 'source <(kubectl completion bash)' >>~/.bashrc
source <(kubectl completion bash)

# Download eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_$ARCH.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
echo 'source <(eksctl completion bash)' >>~/.bashrc
source <(eksctl completion bash)

# Download helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash