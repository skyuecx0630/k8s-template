## Ref
https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html

## create policy

```bash
cat >my-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::my-pod-secrets-bucket"
        }
    ]
}
EOF
```

```bash
aws iam create-policy --policy-name my-policy --policy-document file://my-policy.json
```

## create IRSA

```bash
eksctl create iamserviceaccount \
    --name <SERVICE_ACCOUNT_NAME> \
    --namespace <NAMESPACE> \
    --cluster <CLUSTER_NAME> \
    --role-name <ROLE_NAME> \
    --attach-policy-arn <POLICY_ARN> \
    --approve
```

## configure pod

`pod.spec.serviceAccountName: my-service-account`