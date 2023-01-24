## Install EBS CSI driver
1. Create IRSA
```bash
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole
```

2. Create Addon

Required permission to create addon
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CreateAddon",
      "Effect": "Allow",
      "Action": [
        "eks:DeleteAddon",
        "eks:UpdateAddon",
        "eks:CreateAddon",
        "eks:DescribeAddon"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PassDriverRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::856210586235:role/AmazonEKS_EBS_CSI_DriverRole"
    }
  ]
}
```

```bash
eksctl create addon \
    --name aws-ebs-csi-driver \
    --cluster my-cluster \
    --service-account-role-arn arn:aws:iam::111122223333:role/AmazonEKS_EBS_CSI_DriverRole \
    --force
```