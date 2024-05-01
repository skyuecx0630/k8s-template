# Cluster HPA

## Install Metrics server & Cluster autoscaler

- [Descheduler helm chart](https://github.com/kubernetes-sigs/descheduler/tree/master/charts/descheduler)
- [Cluster Autoscaler helm chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler)

```bash
#!/bin/bash -eux

# Install Descheduler
helm repo add descheduler https://kubernetes-sigs.github.io/descheduler/
helm upgrade --install descheduler -n kube-system descheduler/descheduler \
    --set deschedulerPolicy.strategies.RemovePodsViolatingTopologySpreadConstraint.params.includeSoftConstraints=true \
    $HELM_TOLERATION

# Install metrics server
# --set containerPort=10251 is required for Fargate
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system \
    # --set containerPort=10251 \
    $HELM_TOLERATION

# Craete IAM poilcy for IRSA
cat << EOF > /tmp/cluster-autoscaler-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeTags",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeLaunchTemplateVersions"
        ],
        "Resource": ["*"]
        },
        {
        "Effect": "Allow",
        "Action": [
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "ec2:DescribeImages",
            "ec2:GetInstanceTypesFromInstanceRequirements",
            "eks:DescribeNodegroup"
        ],
        "Resource": ["*"]
        }
    ]
}
EOF

aws iam create-policy \
--policy-name AmazonEKSClusterAutoscalerPolicy \
--policy-document file:///tmp/cluster-autoscaler-policy.json

# Create IRSA
eksctl create iamserviceaccount \
    --cluster=$CLUSTER \
    --namespace=kube-system \
    --name=cluster-autoscaler \
    --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AmazonEKSClusterAutoscalerPolicy \
    --override-existing-serviceaccounts \
    --approve &

# Install Cluster Autoscaler
helm repo add autoscaler https://kubernetes.github.io/autoscaler

helm upgrade --install aws-cluster-autoscaler autoscaler/cluster-autoscaler -n kube-system \
--set autoDiscovery.clusterName=$CLUSTER \
--set awsRegion=$(aws configure get region) \
--set rbac.serviceAccount.create=false \
--set rbac.serviceAccount.name=cluster-autoscaler \
--set extraArgs.ignore-daemonsets-utilization=true \
$HELM_TOLERATION \
# --set image.tag=$SPECIFY_IMAGE_VERSION \
```
