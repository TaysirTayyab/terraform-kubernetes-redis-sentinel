resource "kubernetes_deployment" "redis_master" {
  metadata {
    name      = "${local.master_pod_name}"
    namespace = "${var.kube_namespace}"
  }

  spec {
    # should never be more than 1 replica, use var.redis_slave_replicas for
    # scaling HA
    replicas = 1

    selector {
      match_labels {
        name = "${local.master_pod_name}"
      }
    }

    template {
      metadata {
        labels {
          name = "${local.master_pod_name}"
        }
      }

      spec {
        container {
          name  = "${local.master_pod_name}"
          image = "${var.redis_image}"

          command = ["redis-server"]

          args = [
            "/etc/redis/redis.conf",
            "--slave-announce-ip ${kubernetes_service.redis_master.metadata.0.name}",
            "--slave-announce-port ${var.redis_service_port}",
            "--protected-mode",
            "no",
          ]

          env {
            name  = "config-file-hash"
            value = "${md5(data.template_file.redis_node_config.rendered)}"
          }

          port {
            container_port = "${data.template_file.redis_node_config.vars.server_port}"
          }

          volume_mount {
            name       = "redis-config"
            mount_path = "/etc/redis"
          }

          volume_mount {
            name       = "redis-master-data"
            mount_path = "/data"
          }
        }

        volume {
          name = "redis-config"

          config_map {
            name = "${kubernetes_config_map.redis_node_config.metadata.0.name}"
          }
        }

        volume {
          name      = "redis-master-data"
          empty_dir = {}
        }

        image_pull_secrets {
          name = "${var.redis_image_pull_secret}"
        }
      }
    }
  }
}

resource "kubernetes_service" "redis_master" {
  metadata {
    name      = "${local.master_pod_name}"
    namespace = "${var.kube_namespace}"
  }

  spec {
    type = "ClusterIP"

    selector {
      name = "${local.master_pod_name}"
    }

    port {
      port        = "${var.redis_service_port}"
      target_port = "${data.template_file.redis_node_config.vars.server_port}"
    }
  }
}
