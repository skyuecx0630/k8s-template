## AWS Load Balancer Controller

## IAM Role policy
만약 bastion role로 작업할 때 OIDC 연동 시 아래와 같은 권한 필요
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "iam:GetOpenIDConnectProvider",
        "iam:TagOpenIDConnectProvider",
        "iam:CreateOpenIDConnectProvider",
        "eks:TagResource"
      ],
      "Resource": "*"
    }
  ]
}
```


## IAM Roles for Service Account(IRSA)

1. IAM - OIDC Provider 생성

```bash
eksctl utils associate-iam-oidc-provider \
    --region <region-code> \
    --cluster <your-cluster-name> \
    --approve
```

2. IAM - Policy 생성

```bash
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.6/docs/install/iam_policy.json
```
```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
```

3. IAM - Role 생성

    ```bash
    eksctl create iamserviceaccount \
        --cluster=<cluster-name> \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
        --override-existing-serviceaccounts \
        --approve
    ```

4. TargetGroupBinding CRDs 생성

    ```bash
    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
    ```

5. Helm - Repo 추가

    ```bash
    helm repo add eks https://aws.github.io/eks-charts
    ```

6. Helm - Install from chart

    ```bash
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=<cluster-name> \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
    ```

    - if you have tolerations options
    
        ```bash
        helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
            -n kube-system \
            --set clusterName=<cluster-name> \
            --set serviceAccount.create=false \
            --set serviceAccount.name=aws-load-balancer-controller \
            --set tolerations\[0\].key="key01" \
            --set tolerations\[0\].value="value01" \
            --set tolerations\[0\].effect="NoSchedule"
        ```
7. Subnet Tag 추가

    Subnet Discovery를 위해 Subnet에 태그를 추가합니다.

    - public & private subnets

        `kubernetes.io/cluster/${cluster-name}`: `owned` or `shared`

    - public subnets

        `kubernetes.io/role/elb` : `1`

    - private subnets

        `kubernetes.io/role/internal-elb` : `1`