# CHANGE LOG

The change log is versioned as major.minor.patch. The major version corresponds to the version of redis. So for example v4.X.X will always be redis 4.

## v4.4.0

* **added** `include_prometheus_exporter` to also deploy a prometheus exporter that monitors the cluster master

## v4.3.0

* fixed a bug where master was failing to update it's config file on boot
* fixed a bug where a master failed-over to a slave would put the cluster in an unrecoverable state if slaves were restarted
* **BREAKING** **removed** output variable `sentinel_service`
* **BREAKING** **removed** output variable `sentinel_ip`
* **added** output `sentinel_services`, which is a list of unique hostnames for each sentinel pod. These should be used with the sentinel port to generate host:port lists to pass to applications

### Migration Instructions

Unique pod identifers should be passed to applications to ensure rolling restarts on the sentinels do not break the rest of the cluster.

```hcl
sentinel_nodes = "${join(",", formatlist("%s:${module.redis.sentinel_port}", module.redis.sentinel_services))"
```

## v4.2.1

* fixes a bug where update_policy doesn't apply correctly on Google

## v4.2.0

* **BREAKING** added support for terraform kubernetes provider v1.8.0

### Migration Instructions

For consumers that are not able to update their kubernetes provider version across projects, a separate provider alias should be created and passed into the module call.

```hcl
provider "kubernetes" {
  version = ">=1.8.0"
  alias = "redis"
}

module "redis" {
  provider = "kubernetes.redis"
}
```

## v4.1.0

* added support for Redis authentication.

## v4.0.1

* minor updates to documentation.

## v4.0.0

* initial commit. tagged as v4 since this version is for redis 4.
