#!/bin/bash

INGRESS_NAME="myapp"
INGRESS_NAMESPACE="default"

# Install KEDA operator and metrics server
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm upgrade --install keda \
    --namespace keda \
    --create-namespace \
    kedacore/keda \
    $HELM_TOLERATION

# Create IRSA for ScaledObject to query CloudWatch metrics
eksctl create iamserviceaccount \
    --cluster=$CLUSTER \
    --namespace=keda \
    --name=keda-operator \
    --role-name=keda-operator-role \
    --attach-policy-arn=arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess \
    --override-existing-serviceaccounts \
    --approve &
