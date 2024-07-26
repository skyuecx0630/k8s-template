#!/bin/bash

NAMESPACE="kube-system"
SERVICE_ACCOUNT_NAME="aws-node-termination-handler"
CHART_VERSION="0.24.0"

AUTOSCALING_GROUP_NAME="skills-eks-nodegroup"
QUEUE_NAME="node-termination-handler-queue"
ROLE_NAME="nth-role"
POLICY_NAME="nth-policy"


aws autoscaling create-or-update-tags \
  --tags ResourceId=$AUTOSCALING_GROUP_NAME,ResourceType=auto-scaling-group,Key=aws-node-termination-handler/managed,Value=,PropagateAtLaunch=true

cat << EOF > /tmp/nth-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeTags",
                "ec2:DescribeInstances",
                "sqs:DeleteMessage",
                "sqs:ReceiveMessage"
            ],
            "Resource": "*"
        }
    ]
}
EOF

aws iam create-policy --policy-name $POLICY_NAME --policy-document file:///tmp/$POLICY_NAME.json --query Policy.Arn --output text

eksctl create iamserviceaccount \
    --name $SERVICE_ACCOUNT_NAME \
    --namespace $NAMESPACE \
    --cluster $CLUSTER \
    --role-name $ROLE_NAME \
    --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/nth-policy \
    --override-existing-serviceaccounts \
    --approve &

aws ecr-public get-login-password | helm registry login \
     --username AWS \
     --password-stdin public.ecr.aws

helm upgrade --install aws-node-termination-handler \
  --namespace $NAMESPACE \
  --set serviceAccount.create=false \
  --set serviceAccount.name=$SERVICE_ACCOUNT_NAME \
  --set enableSqsTerminationDraining=true \
  --set queueURL=https://sqs.$(aws configure get region).amazonaws.com/$AWS_ACCOUNT_ID/$QUEUE_NAME \
  oci://public.ecr.aws/aws-ec2/helm/aws-node-termination-handler --version $CHART_VERSION

