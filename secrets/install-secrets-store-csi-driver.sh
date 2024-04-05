#!/bin/bash

helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws

helm upgrade --install -n kube-system csi-secrets-store \
    --set syncSecret.enabled=true \
    --set enableSecretRotation=true \
    --set rotationPollInterval=5s \
    secrets-store-csi-driver/secrets-store-csi-driver

helm upgrade --install -n kube-system secrets-provider-aws \
    aws-secrets-manager/secrets-store-csi-driver-provider-aws
