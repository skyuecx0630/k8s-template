# patch

Deployment들의 설정 값을 바꾸고 싶을 떄가 있을 것이다. 다른 설정값을 건드리지 않고 추가하는 patch를 이 문서에서 다룬다.

## patch add deployment

```bash
kubectl patch deployment <DEPLOYMENT> --type merge --patch-file patch-deployment.yaml
```

## helm toleration and nodeSelector option

```bash
--set tolerations\[0\].key="management" \
--set tolerations\[0\].value="addon" \
--set tolerations\[0\].effect="NoSchedule" \
--set nodeSelector.management=addon \
```