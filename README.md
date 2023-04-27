# k8s template

This repository manages useful templates and scripts for operating and deploying k8s resources.

All scripts are written for EKS cluster.

## for Amazon Linux 2

Run [install_tools.sh](./install_tools.sh). Script will setup `kubectl`, `eksctl`, `helm`, `k9s` and environment variables.

## for Windows

All commands should be run as administrator

### Install Chocolatey
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Install CLI tools

```powershell
choco install -y kubernetes-cli eksctl kubernetes-helm k9s
```
