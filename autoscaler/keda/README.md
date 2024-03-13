# KEDA

- [ScaledObject Spec](https://keda.sh/docs/2.13/concepts/scaling-deployments/#scaledobject-spec)
- [Trigger scaling with Amazon CloudWatch](https://keda.sh/docs/2.13/scalers/aws-cloudwatch/)

```bash
TARGET_GROUP_IDENTIFIER=$(
    kubectl get targetgroupbindings.elbv2.k8s.aws -o yaml \
    | yq .items[].spec.targetGroupARN | tr -d '"' | awk -F ":" '{ print $NF }'
)
```

```bash
ALB_IDENTIFIER=$(
    aws elbv2 describe-load-balancers \
        --names $(
            kubectl get ing -o json | jq '.items[].metadata.annotations."alb.ingress.kubernetes.io/load-balancer-name"' | tr -d '"'
        ) \
        --query "LoadBalancers[].LoadBalancerArn" \
        --output text | awk -F ':' '{ print $NF }' | cut -d / -f 2-
)
```
