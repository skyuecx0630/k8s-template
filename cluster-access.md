# Cluster Access

## Cluster created by IAM user

When a cluster is set up for the first time, only a user who created EKS cluster can access to it.

This user can make other users/roles to access to a cluster.

```bash
eksctl create iamidentitymapping \
  --cluster $CLUSTER \
  --arn arn:aws:iam::$AWS_ACCOUNT_ID:user/<USER_NAME> \
  --username cluster-admin \
  --group system:masters
```

```bash
aws eks update-kubeconfig \
  --name $CLUSTER
```

## IAM policy for IAM role

You need following permissions to control EKS cluster. Attach this policy to your role.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EKSClusterAccess",
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "*"
        },
        {
            "Sid": "CreateIRSA",
            "Effect": "Allow",
            "Action": [
                "iam:CreatePolicy",
                "iam:GetRole",
                "iam:DetachRolePolicy",
                "iam:UntagRole",
                "iam:TagRole",
                "iam:DeletePolicy",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "cloudformation:ListStacks",
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CreateOIDCProvider",
            "Effect": "Allow",
            "Action": [
                "eks:UntagResource",
                "eks:TagResource",
                "iam:UntagOpenIDConnectProvider",
                "iam:DeleteOpenIDConnectProvider",
                "iam:GetOpenIDConnectProvider",
                "iam:TagOpenIDConnectProvider",
                "iam:CreateOpenIDConnectProvider"
            ],
            "Resource": "*"
        }
    ]
}
```