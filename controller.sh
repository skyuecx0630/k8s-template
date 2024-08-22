#!/bin/bash

REGION=$(aws configure get region)

# ==================================================
# Create IRSA
# ==================================================
ISSUER_URL=$(aws eks describe-cluster --name $CLUSTER --query cluster.identity.oidc.issuer --output text)
ISSUER_HOSTPATH=$(echo $ISSUER_URL | cut -f 3- -d'/')
PROVIDER_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:oidc-provider/$ISSUER_HOSTPATH"

create_irsa () {
    NAMESPACE=$1
    SERVICE_ACCOUNT_NAME=$2
    ROLE_NAME=$3

    cat > /tmp/${ROLE_NAME}-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "$PROVIDER_ARN"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${ISSUER_HOSTPATH}:sub": "system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}"
        }
      }
    }
  ]
}
EOF

    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document file:///tmp/${ROLE_NAME}-trust-policy.json \
        --no-cli-pager

    kubectl create sa -n $NAMESPACE $SERVICE_ACCOUNT_NAME
    kubectl annotate sa -n $NAMESPACE $SERVICE_ACCOUNT_NAME \
        eks.amazonaws.com/role-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}
}

attach_policy_to_role () {
    ROLE_NAME=$1
    POLICY_ARN=$2

    aws iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn $POLICY_ARN \
        --no-cli-pager
}


# ==================================================
# Custom poilcies
# ==================================================

create_cluster_autoscaler_policy () {
    cat << 'EOF' > /tmp/cluster-autoscaler-policy.json
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
}

create_aws_load_balancer_controller_policy () {
    # Download IAM policy for IRSA
    curl -so /tmp/iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.1/docs/install/iam_policy.json

    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file:///tmp/iam-policy.json
}


# ==================================================
# Install K8s controllers
# ==================================================

install_metrics_server () {
    # Install metrics server
    # --set containerPort=10251 is required for Fargate
    helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
    helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system \
        $HELM_TOLERATION
        # --set containerPort=10251 \
}

install_cluster_autoscaler () {
    ROLE_NAME="cluster-autoscaler-role"
    SERVICE_ACCOUNT_NAME="cluster-autoscaler"

    create_cluster_autoscaler_policy
    create_irsa kube-system $SERVICE_ACCOUNT_NAME $ROLE_NAME
    attach_policy_to_role $ROLE_NAME arn:aws:iam::$AWS_ACCOUNT_ID:policy/AmazonEKSClusterAutoscalerPolicy

    # Install Cluster Autoscaler
    helm repo add autoscaler https://kubernetes.github.io/autoscaler

    helm upgrade --install aws-cluster-autoscaler autoscaler/cluster-autoscaler -n kube-system \
    --set autoDiscovery.clusterName=$CLUSTER \
    --set awsRegion=$REGION \
    --set rbac.serviceAccount.create=false \
    --set rbac.serviceAccount.name=$SERVICE_ACCOUNT_NAME \
    --set extraArgs.ignore-daemonsets-utilization=true \
    $HELM_TOLERATION
}

install_keda () {
    ROLE_NAME="keda-operator-role"
    SERVICE_ACCOUNT_NAME="keda-operator"

    helm repo add kedacore https://kedacore.github.io/charts
    helm repo update
    helm upgrade --install keda \
        --namespace keda \
        --create-namespace \
        kedacore/keda \
        $HELM_TOLERATION

    # Create IRSA for ScaledObject to query CloudWatch metrics
    create_irsa keda $SERVICE_ACCOUNT_NAME $ROLE_NAME
    attach_policy_to_role $ROLE_NAME arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess
}


install_aws_load_balancer_controller () {
    ROLE_NAME="aws-load-balancer-controller-role"
    SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"

    # Create IRSA for AWS Load Balancer controller
    create_aws_load_balancer_controller_policy
    create_irsa kube-system $SERVICE_ACCOUNT_NAME $ROLE_NAME
    attach_policy_to_role $ROLE_NAME arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy

    # Create TargetGroup CRD
    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master" &

    # Deploy AWS Load Balancer controller with toleration
    helm repo add eks https://aws.github.io/eks-charts

    helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER \
        --set serviceAccount.create=false \
        --set serviceAccount.name=$SERVICE_ACCOUNT_NAME \
        --set region=$REGION \
        --set vpcId=$(aws eks describe-cluster --name $CLUSTER --query cluster.resourcesVpcConfig.vpcId --output text) \
        $HELM_TOLERATION
}


# install_aws_load_balancer_controller
# install_metrics_server
# install_cluster_autoscaler
# install_keda


# create_irsa skills root skills-root-role
