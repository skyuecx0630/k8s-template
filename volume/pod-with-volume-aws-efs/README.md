# Pod with volume using AWS EFS

## Install aws-efs-csi-driver

```bash
#!/bin/bash -eux
# Create IRSA for EFS CSI Driver
curl -so /tmp/efs-csi-driver-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json

aws iam create-policy \
    --policy-name AmazonEKS_EFS_CSI_Driver_Policy \
    --policy-document file:///tmp/efs-csi-driver-policy.json

eksctl create iamserviceaccount \
    --cluster $CLUSTER \
    --namespace kube-system \
    --name efs-csi-controller-sa \
    --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/AmazonEKS_EFS_CSI_Driver_Policy \
    --approve

# Deploy EFS CSI Driver with toleration
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/

helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.$(aws configure get region).amazonaws.com/eks/aws-efs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=efs-csi-controller-sa \
    --set controller.tolerations[0].key=$TOLERATION_KEY \
    --set controller.tolerations[0].value=$TOLERATION_VALUE \
    --set controller.tolerations[0].effect=NoSchedule \
    --set controller.nodeSelector.$TOLERATION_KEY=$TOLERATION_VALUE
```
