#!/bin/bash

KARPENTER_VERSION="v0.33.0"
KARPENTER_NAMESPACE="karpenter"
KARPENTER_IAM_ROLE_ARN="arn:aws:iam::856210586235:role/KarpenterControllerRole-skills-cluster"

helm logout public.ecr.aws

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" \
  --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=${KARPENTER_IAM_ROLE_ARN}" \
  --set "settings.clusterName=${CLUSTER_NAME}"
