# Install reloader

https://github.com/stakater/Reloader

```bash
helm repo add stakater https://stakater.github.io/stakater-charts
helm repo update
helm upgrade --install reloader stakater/reloader \
    $HELM_TOLERATION
```

## Annotations

```yaml
# Doesn't work with csi-secrets-store
reloader.stakater.com/auto: "true"

# Reload on specific cm/secret changes
secret.reloader.stakater.com/reload: "database"
configmap.reloader.stakater.com/reload: "myconfig"
```