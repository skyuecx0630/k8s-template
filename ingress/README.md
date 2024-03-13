# AWS Load Balancer Controller

## Subnet Discovery

If you want to automatically discover subnets and deploy ALB to these, you can tag resources.

- public & private subnets

`kubernetes.io/cluster/${cluster-name}`: `owned` or `shared`

- public subnets

`kubernetes.io/role/elb` : `1`

- private subnets

`kubernetes.io/role/internal-elb` : `1`
