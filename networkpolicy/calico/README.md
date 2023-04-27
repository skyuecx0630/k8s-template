# Calico operator

## Install Calico

```bash
#!/bin/bash -eux
CALICO_VERSION='v3.25.1'

# Add Helm repo
kubectl create namespace calico-system
helm repo add projectcalico https://docs.projectcalico.org/charts
helm repo update

# Install Calico
cat << EOF > /tmp/calico-values.yaml
installation:
  kubernetesProvider: EKS
  controlPlaneTolerations: # if you need taint/toleration.
  - key: $TOLERATION_KEY
    value: $TOLERATION_VALUE
    effect: NoSchedule
EOF

helm install calico projectcalico/tigera-operator --version $CALICO_VERSION --namespace calico-system -f /tmp/calico-values.yaml
```
