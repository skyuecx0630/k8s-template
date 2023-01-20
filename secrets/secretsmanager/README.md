## aws secrets manager
1. ASCP install

```
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver

helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws
helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws

```

2. Pod IRSA 생성

Pod의 ServiceAccount에 `secretsmanager:GetSecretValue`, `secretsmanager:DescribeSecret` 권한을 부여해야 합니다.

3. SecretProviderClass 생성
   
Template을 참고하여 SecretProviderClass 생성 후 Pod에 마운트 합니다.