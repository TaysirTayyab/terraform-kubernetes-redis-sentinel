variable "redis_image" {
  description = "The redis image for the master, slaves, and sentinels."
  default     = "gcr.io/cloud-marketplace/google/redis4:latest"
}

variable "redis_auth" {
  description = "Password to access the Redis database"
  default     = ""
}

variable "redis_image_pull_secret" {
  description = "The credentials used to authorize to the container registry."
}

variable "kube_namespace" {
  description = "The k8s namespace where the redis cluster will be deployed."
  default     = "default"
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
