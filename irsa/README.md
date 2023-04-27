
## Create IRSA for pod

### YOU SHOULD DEFINE YOUR OWN POLICY AND OTHER VARIABLES

```bash
#!/bin/bash -eux
SERVICE_ACCOUNT_NAME=''
NAMESPACE=''
ROLE_NAME=''

# Create policy for IRSA
cat << EOF > /tmp/my-policy.json
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

POLICY_ARN=$(aws iam create-policy --policy-name my-policy --policy-document file:///tmp/my-policy.json --query Policy.Arn --output text)

# Create IRSA
eksctl create iamserviceaccount \
    --name $SERVICE_ACCOUNT_NAME \
    --namespace $NAMESPACE \
    --cluster $CLUSTER \
    --role-name $ROLE_NAME \
    --attach-policy-arn $POLICY_ARN \
    --override-existing-serviceaccounts \
    --approve
```

## Ref
https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html