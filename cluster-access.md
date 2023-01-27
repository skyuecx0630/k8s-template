# Cluster Access

## Cluster created by IAM user

cluster에 처음으로 접근할 땐 cluster를 생성한 user or role로 접근해야 함. 이후 aws-auth 수정하여 다른 identity에 권한 부여 가능.

```bash
eksctl create iamidentitymapping \
  --cluster <CLUSTER_NAME> \
  --arn arn:aws:iam::<ACCOUNT_ID>:user/<USER_NAME> \
  --username cluster-admin \
  --group system:masters
```

```bash
aws eks update-kubeconfig \
  --name <CLUSTER_NAME> \
```

## Access for IAM role

[aws-auth.yaml](aws-auth.yaml) 파일 참고하여 configmap/aws-auth에 map-role 등록

`eks:DescribeCluster` 권한을 부여해주면 아래의 명령어로 클러스터 접근 권한을 얻을 수 있다.

```bash
aws eks update-kubeconfig \
  --name <CLUSTER_NAME> \
```

## IAM Policies for IAM role

Bastion host에서 작업할 때 EKS를 조작하기 위한 최소한의 권한에 대해 다루고 있습니다. 필요에 따라 적용하면 됩니다.

### EKS Access
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EKSClusterAccess",
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "*"
        }
    ]
}
```

### Create OIDC Provider & Create IRSA(IAM Role for Service Account)
```json
{
    "Version": "2012-10-17",
    "Statement": [
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