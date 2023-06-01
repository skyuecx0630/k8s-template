#!/bin/bash -eu
# Determine k8s version and host architecture
KUBEVERSION=v1.27.2
CLUSTER_NAME='skills-cluster'
TOLERATION_KEY='management'
TOLERATION_VALUE='addon'
ARCH=""
case $(uname -m) in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
esac

# Install git
sudo yum install -y git jq

# Download kubectl
curl -LO "https://dl.k8s.io/release/$KUBEVERSION/bin/linux/$ARCH/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source <(kubectl completion bash)

# Download eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_$ARCH.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
echo 'source <(eksctl completion bash)' >> ~/.bashrc
source <(eksctl completion bash)

# Download helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Download k9s
curl -sL https://github.com/derailed/k9s/releases/download/v0.27.3/k9s_Linux_$ARCH.tar.gz | tar xz -C /tmp
sudo mv /tmp/k9s /usr/local/bin

# Configure EKS variables on shell login
cat << EOF > ~/.kubevar.sh
#!/bin/bash -eux

case \$(uname -m) in
    x86_64) export ARCH="amd64" ;;
    aarch64) export ARCH="arm64" ;;
esac

CLUSTER='$CLUSTER_NAME' && export CLUSTER
AWS_ACCOUNT_ID=\$(aws sts get-caller-identity --query "Account" --output text) && export AWS_ACCOUNT_ID
TOLERATION_KEY='$TOLERATION_KEY' && export TOLERATION_KEY
TOLERATION_VALUE='$TOLERATION_VALUE' && export TOLERATION_VALUE
HELM_TOLERATION='--set tolerations[0].key='\$TOLERATION_KEY' --set tolerations[0].value='\$TOLERATION_VALUE' --set tolerations[0].effect=NoSchedule --set nodeSelector.'\$TOLERATION_KEY'='\$TOLERATION_VALUE && export HELM_TOLERATION
EOF

source ~/.kubevar.sh
echo "source ~/.kubevar.sh" >> ~/.bashrc
