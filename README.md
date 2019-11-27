# Redis Cluster w/ Sentinel

This Terraform module deploys resources to a Kubernetes cluster to run a redis instance with sentinel support.

* 1 redis master
* 3 (configurable) redis slaves
* 3 (configurable) redis sentinels

Slaves and sentinels are configured with anti-affinity to spread the replicas across nodes. Sentinels will automatically detect slaves from the master.

## Usage

**This module requires v1.8.0 or newer of the terraform kubernetes provider!**

The module is designed to function with minimal bootstrapping. Just provide the image pull secret for the redis image and the module will handle the rest.

```hcl
module "redis" {
  source = "git::git@wwwin-github.cisco.com:broadcloud-iac/terraform-kubernetes-redis-sentinel.git"

  redis_image_pull_secret = "${kubernetes_secret.redis_image_pull_secret.metadata.0.name}"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| include\_prometheus\_exporter | True to also deploy the prometheus exporter for redis. | string | `"false"` | no |
| kube\_namespace | The k8s namespace where the redis cluster will be deployed. MUST be less than or equal to 9 characters! | string | `"default"` | no |
| redis\_auth | Password to access the Redis database | string | `""` | no |
| redis\_image | The redis image for the master, slaves, and sentinels. | string | `"gcr.io/cloud-marketplace/google/redis4:latest"` | no |
| redis\_image\_pull\_secret | The credentials used to authorize to the container registry. | string | n/a | yes |
| redis\_service\_port | The port used to connect to the redis service. | string | `"6379"` | no |
| redis\_slave\_replicas | The number of redis slave replicas to run. | string | `"3"` | no |
| sentinel\_replicas | The number of sentinel replicas to run. | string | `"3"` | no |
| sentinel\_service\_port | The port used to connect to the redis sentinel service. | string | `"26379"` | no |

## Outputs

| Name | Description |
|------|-------------|
| master\_ip | The ip address of the master service. |
| master\_port | The port to connect to the redis master. |
| master\_service | The routable name for the master replica. |
| sentinel\_monitored\_master | The name of the (default) redis master. |
| sentinel\_port | The port for the sentinel replicas. |
| sentinel\_services | The routable names for the sentinel replicas. |
