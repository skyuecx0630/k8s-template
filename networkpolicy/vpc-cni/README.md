# TL;DR

- Configure VPC CNI
```sh
kubectl set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true
kubectl set env daemonset aws-node -n kube-system POD_SECURITY_GROUP_ENFORCING_MODE=standard
```
- After aws-node restarts, `kubectl get cninode -A` must return some resources
- Apply security group policies
- Restart app pods


# Reference
- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/security-groups-for-pods.html