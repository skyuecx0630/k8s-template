# patch

Deployment들의 설정 값을 바꾸고 싶을 떄가 있을 것이다. 다른 설정값을 건드리지 않고 추가하는 patch를 이 문서에서 다룬다.

## patch add deployment

```bash
kubectl patch deployment <DEPLOYMENT> --type merge --patch-file patch-deployment.yaml
```

## patch coredns
```bash
kubectl patch deployments.apps coredns -n kube-system --type merge --patch '{"spec": {"template": {"spec": {"nodeSelector": {"'$TOLERATION_KEY'": "'$TOLERATION_VALUE'"}, "tolerations": [{"key": "'$TOLERATION_KEY'", "value": "'$TOLERATION_VALUE'", "effect": "NoSchedule"}]}}}}'
```

## helm toleration and nodeSelector option

```bash
--set tolerations\[0\].key="$TOLERATION_KEY" \
--set tolerations\[0\].value="$TOLERATION_VALUE" \
--set tolerations\[0\].effect="NoSchedule" \
--set nodeSelector.$TOLERATION_KEY=$TOLERATION_VALUE
```