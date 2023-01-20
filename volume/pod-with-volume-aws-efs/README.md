# Pod with volume using AWS EFS

## Create service account using AWS IAM

1. Create policy 

```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json

aws iam create-policy \
    --policy-name AmazonEKS_EFS_CSI_Driver_Policy \
    --policy-document file://iam-policy-example.json
```

2. Create IRSA
```bash
eksctl create iamserviceaccount \
    --cluster my-cluster \
    --namespace kube-system \
    --name efs-csi-controller-sa \
    --attach-policy-arn arn:aws:iam::111122223333:policy/AmazonEKS_EFS_CSI_Driver_Policy \
    --approve
```

[AWS Documentation](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/efs-csi.html#efs-create-iam-resources)

## Install EFS driver in Kubernetes

1. Add helm repo
```bash
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/

helm repo update
```

2. Install EFS Driver
  
Region에 따라 Account ID도 다를 수 있음. [Check it out here](https://marcus16-kang.github.io/aws-resources-example/Containers/EKS/12-using-efs/#:~:text=You%20should%20check,AWS%20Documentation)
```bash
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.<region code>.amazonaws.com/eks/aws-efs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=efs-csi-controller-sa
```

## Using EFS

> EFS와 EKS node간에 Security group(반드시 EKS의 primary security group) 등 네트워크 설정이 잘 되었는지 확인해야 함
>
> Managed node group을 사용할 경우 OS에 efs-utils가 이미 설정되어 있어 문제가 없으나, 그 이외에는 반드시 OS에 efs-utils가 있어야 함
>
> Dynamic provisioning의 경우, uid, gid 등 POSIX 설정에서 오류가 자주 발생함

[AWS EFS CSI Driver Examples](https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes)

[AWS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html#efs-sample-app)