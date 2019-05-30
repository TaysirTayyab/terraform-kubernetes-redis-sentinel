# Redis Cluster w/ Sentinel

This Terraform module deploys resources to a Kubernetes cluster to run a redis instance with sentinel support.

* 1 redis master
* 3 (configurable) redis slaves
* 3 (configurable) redis sentinels

Slaves and sentinels are configured with anti-affinity to spread the replicas across nodes. Sentinels will automatically detect slaves from the master.

## Usage

The module is designed to function with minimal bootstrapping. Just provide the provider alias for the kubernetes cluster and the image pull secret for the redis image and the module will handle the rest.

```hcl
module "redis" {
  source = "git::git@wwwin-github.cisco.com:broadcloud-iac/terraform-kubernetes-redis-sentinel.git"

  redis_image_pull_secret = "${kubernetes_secret.redis_image_pull_secret.metadata.0.name}"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| kube_namespace | The k8s namespace where the redis cluster will be deployed. | string | `default` | no |
| redis_image | The redis image for the master, slaves, and sentinels. | string | `gcr.io/cloud-marketplace/google/redis4:latest` | no |
| redis_image_pull_secret | The credentials used to authorize to the container registry. | string | - | yes |
| redis_service_port | The port used to connect to the redis service. | string | `6379` | no |
| redis_slave_replicas | The number of redis slave replicas to run. | string | `3` | no |
| sentinel_replicas | The number of sentinel replicas to run. | string | `3` | no |
| sentinel_service_port | The port used to connect to the redis sentinel service. | string | `26379` | no |
| redis_auth | Set this value to password protect the Redis instances. Disabled by default. | string |  | no |

## Outputs

| Name | Description |
|------|-------------|
| master_ip | The ip address of the master service. |
| master_port | The port to connect to the redis master. |
| master_service | The routable name for the master service. |
| sentinel_ip | The ip address of the sentinel service. |
| sentinel_monitored_master | The name of redis master being monitored by redis. |
| sentinel_port | The port for the sentinel service. |
| sentinel_service | The routable name for the sentinel service. |
