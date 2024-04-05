#!/bin/bash

helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws

# Best practice is not to set syncSecret.enabled=true. If to do so, enable KMS encryption for cluster.
helm upgrade --install -n kube-system csi-secrets-store \
    --set syncSecret.enabled=false \
    --set enableSecretRotation=true \
    --set rotationPollInterval=5s \
    secrets-store-csi-driver/secrets-store-csi-driver

helm upgrade --install -n kube-system secrets-provider-aws \
    aws-secrets-manager/secrets-store-csi-driver-provider-aws
