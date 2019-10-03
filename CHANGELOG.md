# CHANGE LOG

The change log is versioned as major.minor.patch. The major version corresponds to the version of redis. So for example v4.X.X will always be redis 4.

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
