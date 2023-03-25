## installation

```bash
kubectl create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm

helm upgrade --install argocd -n argocd argo/argo-cd \
--set crds.keep=false \
--set global.tolerations\[0\].key="management" \
--set global.tolerations\[0\].value="addon" \
--set global.tolerations\[0\].effect="NoSchedule" \
--set global.nodeSelector.management=addon
```

## argocd cli setup

```bash
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd
sudo yum install -y jq
```

## argocd-server access

Classic Load Balancer로 server를 외부로 노출시킴.

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

로컬 환경에서만 접근 가능

```bash
kubectl port-forward service/argocd-server -n argocd 8080:443
```

## argocd cli login to server

```bash
## exposing server endpoint
# export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output .status.loadBalancer.ingress[0].hostname`

# not exposing, but port-forwarding
export ARGOCD_SERVER="localhost:8080"
export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

argocd login $ARGOCD_SERVER --username admin --password $ARGO_PWD --insecure
```

### argocd codecommit as repository

Repository에 ssh 연결을 하게 될텐데, codecommit의 경우 SSH public key를 등록해줘야 한다.

```bash
ssh-keyscan git-codecommit.<REGION>.amazonaws.com | argocd cert add-ssh --batch
```

## argocd repository

argocd가 설치된 node의 **outbound ssh** 허용

vpc endpoint가 활성화 된 경우, endpoint의 **inbound ssh** 또한 허용

SSH_GIT_REPOSITORY는 `ssh://<USER>@<GIT_REPOSITORY>` 형태의 URL

```bash
argocd repo add <SSH_GIT_REPOSITORY> --name <REPO_NAME> --ssh-private-key-path <SSH_KEY_PATH>
```


## argocd application

Directory root에 위치한 파일들을 전부 적용함. 만약 sub directory의 파일까지 적용시키고자 한다면 `--directory-recurse` 옵션 사용.

kustomize를 사용할 경우 path를 `./overlay/prod`와 같이 변경한다.

```bash
argocd app create <APP_NAME> --repo <SSH_GIT_REPOSITORY> --path ./ --dest-server https://kubernetes.default.svc --dest-namespace <NAMESPACE> --sync-policy automated --self-heal --auto-prune
```