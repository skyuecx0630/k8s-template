#!/bin/bash

helm repo add external-secrets https://charts.external-secrets.io

helm upgrade --install external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true \
    external-secrets/external-secrets \
    $HELM_TOLERATION
