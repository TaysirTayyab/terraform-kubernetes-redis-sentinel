variable "redis_image_pull_secret" {}

variable "kube_namespace" {
  default = "default"
}

variable "redis_image" {
  default = "gcr.io/cloud-marketplace/google/redis4:latest"
}

variable "redis_service_port" {
  description = "The port used to connect to the redis service."
  default     = 6379
}

variable "redis_slave_replicas" {
  description = "The number of redis slave replicas to run."
  default     = 3
}

variable "sentinel_service_port" {
  description = "The port used to connect to the redis sentinel service."
  default     = 26379
}

variable "sentinel_replicas" {
  description = "The number of sentinel replicas to run."
  default     = 3
}
