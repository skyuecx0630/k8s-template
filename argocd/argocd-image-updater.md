## install

### prerequisite

k8s application이 `Helm chart`나 `kustomize` 형태로 배포되어야 함.

### IRSA for pulling image

```bash
eksctl create iamserviceaccount \
--cluster=<your-cluster-name> \
--namespace=argocd \
--name=argocd-image-updater \
--attach-policy-arn=arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
--override-existing-serviceaccounts \
--approve
```

### installation

아래의 정보를 바탕으로 `values.yaml`을 수정 후 배포
- ECR registry 정보 
- aws region

```bash
helm upgrade --install argocd-image-updater -n argocd argo/argocd-image-updater -f values.yaml
```

### argocd account

argocd에 연결하기 위한 account를 생성한다.

```bash
kubectl edit configmap argocd-cm -n argocd
```
```yaml
apiVersion: v1
kind: ConfigMap
data:
  accounts.image-updater: apiKey 
```

account에 권한을 부여한다.

```bash
kubectl edit configmap argocd-rbac-cm -n argocd
```
```yaml
apiVersion: v1
kind: ConfigMap
data:
  policy.csv: |
    p, role:image-updater, applications, get, */*, allow
    p, role:image-updater, applications, update, */*, allow
    g, image-updater, role:image-updater
  policy.default: role.readonly
```

secret을 생성하여 image updater가 토큰에 접근하도록 한다.

```bash
TOKEN=`argocd account generate-token --account image-updater --id image-updater`
kubectl create secret generic argocd-image-updater-secret -n argocd --from-literal argocd.token=$TOKEN
```

### annotation

만약 ArgoCD Application 내에 여러 Deployment나 Image를 사용하고 있다면, app=<IMAGE_URL> 에서 app 부분을 여러개로 두어 사용 가능하다.

```bash
kubectl annotate applications <APP_NAME> -n argocd argocd-image-updater.argoproj.io/app.update-strategy=latest argocd-image-updater.argoproj.io/image-list= app=<IMAGE_URL>
```
