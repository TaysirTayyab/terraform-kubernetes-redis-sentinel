resource "kubernetes_service" "redis_slave" {
  metadata {
    name      = "${local.slave_pod_name}"
    namespace = "${var.kube_namespace}"
  }

  spec {
    type = "ClusterIP"

    selector {
      name = "${local.slave_pod_name}"
    }

    port {
      port        = "${var.redis_service_port}"
      target_port = "${data.template_file.redis_node_config.vars.server_port}"
    }
  }
}

resource "kubernetes_stateful_set" "redis_slave" {
  metadata {
    name      = "${local.slave_pod_name}"
    namespace = "${var.kube_namespace}"
  }

  spec {
    service_name = "${kubernetes_service.redis_slave.metadata.0.name}"
    replicas     = "${var.redis_slave_replicas}"

    update_strategy {}

    selector {
      match_labels {
        name = "${local.slave_pod_name}"
      }
    }

    template {
      metadata {
        labels {
          name = "${local.slave_pod_name}"
        }
      }

      spec {
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "name"
                    operator = "In"
                    values   = ["${local.slave_pod_name}"]
                  }
                }

                topology_key = "kubernetes.io/hostname"
              }

              weight = 100
            }
          }
        }

        container {
          name  = "${local.slave_pod_name}"
          image = "${var.redis_image}"

          command = ["redis-server"]

          args = [
            "/etc/redis/redis.conf",
            "--slaveof ${kubernetes_service.redis_master.metadata.0.name} ${var.redis_service_port}",
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
        }

        volume {
          name = "redis-config"

          config_map {
            name = "${kubernetes_config_map.redis_node_config.metadata.0.name}"
          }
        }

        image_pull_secrets {
          name = "${var.redis_image_pull_secret}"
        }
      }
    }
  }
}
