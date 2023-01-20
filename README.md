# k8s template

k8s 클러스터 구성에 필요한 템플릿 및 매뉴얼을 관리하는 레포지토리입니다.

환경은 AWS EKS를 기준으로 작성하였습니다.

## for Amazon Linux 2

### Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/v1.22.1/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
echo 'source <(kubectl completion bash)' >>~/.bashrc
source <(kubectl completion bash)
```

### Install eksctl
```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
echo 'source <(eksctl completion bash)' >>~/.bashrc
source <(eksctl completion bash)
```

### Install helm
```bash
curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2
```

## for Windows

All commands should be run as administrator

### Chocolatey
```powershell
# REF: 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### kubectl

```powershell
# REF : https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-windows/
choco install kubernetes-cli
```

### eksctl

```powershell
choco install -y eksctl 
```

### helm

```powershell
# REF : https://helm.sh/ko/docs/intro/install/
choco install kubernetes-helm
```

### k9s

```powershell
choco install k9s
```