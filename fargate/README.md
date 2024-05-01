# Fargate configuration

## CoreDNS

Properties below should be removed

```bash
kubectl edit -n kube-system deployment/coredns
```


```yaml
affinity:
    nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/os
            operator: In
            values:
            - linux
            - key: kubernetes.io/arch
            operator: In
            values:
            - amd64
            - arm64
    podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - podAffinityTerm:
            labelSelector:
            matchExpressions:
            - key: k8s-app
                operator: In
                values:
                - kube-dns
            topologyKey: kubernetes.io/hostname
        weight: 100
```

## ALB controller

Region and VPC are required for ALB controller, 'cause there's no IMDS in Fargate.

```bash
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region=<REGION> \  
    --set vpcId=<VPC_ID> \ 
    $HELM_TOLERATION
```
