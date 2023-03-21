

## fluentbit 배포

fluentbit를 daemonset으로 배포합니다. 이는 아마존에서 제공해주는 기본 설정을 사용하며, 실제로는 커스텀하여 사용해야 합니다.

create namespace
```bash
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml
```

create configmap
```bash
ClusterName=<my-cluster-name>
RegionName=<my-cluster-region>
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
kubectl create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=${ClusterName} \
--from-literal=http.server=${FluentBitHttpServer} \
--from-literal=http.port=${FluentBitHttpPort} \
--from-literal=read.head=${FluentBitReadFromHead} \
--from-literal=read.tail=${FluentBitReadFromTail} \
--from-literal=logs.region=${RegionName} -n amazon-cloudwatch
```

associate oidc
```bash
eksctl utils associate-iam-oidc-provider \
--cluster <your-cluster-name> \
--approve
```

create irsa
```bash
eksctl create iamserviceaccount \
--cluster=<your-cluster-name> \
--namespace=amazon-cloudwatch \
--name=fluent-bit \
--attach-policy-arn=arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
--override-existing-serviceaccounts \
--approve
```

download `fluent-bit.yaml` file
```
wget https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml
```

modify `fluent-bit.yaml`

- Delete Service Account
- Adjust CPU request according to your instance type