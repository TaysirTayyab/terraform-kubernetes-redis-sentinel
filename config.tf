data "template_file" "redis_node_config" {
  template = "${file("${path.module}/config/redis.conf")}"

  vars = {
    server_port = 6379
  }
}

resource "kubernetes_config_map" "redis_node_config" {
  metadata {
    name      = "redis-node-config"
    namespace = "${var.kube_namespace}"
  }

  data {
    "redis.conf" = "${data.template_file.redis_node_config.rendered}"
  }
}

data "template_file" "sentinel_node_config" {
  template = "${file("${path.module}/config/sentinel.conf")}"

  vars = {
    server_port = 26379
    master_name = "${local.master_pod_name}"
    master_host = "${kubernetes_service.redis_master.metadata.0.name}"
    master_port = "${var.redis_service_port}"
  }
}

resource "kubernetes_config_map" "sentinel_node_config" {
  metadata {
    name      = "sentinel-node-config"
    namespace = "${var.kube_namespace}"
  }

  data {
    "sentinel.conf" = "${data.template_file.sentinel_node_config.rendered}"
  }
}
