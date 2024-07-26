#!/bin/bash -eux
# Create TargetGroup CRD
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master" &

# Download IAM policy for IRSA
curl -so /tmp/iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.1/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file:///tmp/iam-policy.json

# Create IRSA for AWS Load Balancer controller
eksctl create iamserviceaccount \
    --cluster=$CLUSTER \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name=aws-load-balancer-controller-role \
    --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve &

# Deploy AWS Load Balancer controller with toleration
helm repo add eks https://aws.github.io/eks-charts

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region=$(aws configure get region) \
    --set vpcId=$(aws eks describe-cluster --name $CLUSTER --query cluster.resourcesVpcConfig.vpcId --output text) \
    $HELM_TOLERATION