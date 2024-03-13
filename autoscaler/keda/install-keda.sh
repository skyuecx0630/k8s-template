#!/bin/bash

INGRESS_NAME="myapp"
INGRESS_NAMESPACE="default"

# Install KEDA operator and metrics server
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda --namespace keda --create-namespace

# Create IRSA for ScaledObject to query CloudWatch metrics
eksctl create iamserviceaccount \
    --cluster=$CLUSTER \
    --namespace=keda \
    --name=keda-operator \
    --attach-policy-arn=arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess \
    --override-existing-serviceaccounts \
    --approve &
