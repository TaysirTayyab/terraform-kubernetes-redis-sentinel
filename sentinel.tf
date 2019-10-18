resource "kubernetes_service" "redis_sentinel" {
  metadata {
    name      = "${local.sentinel_pod_name}"
    namespace = "${var.kube_namespace}"
  }

  spec {
    type = "ClusterIP"

    selector {
      name = "${local.sentinel_pod_name}"
    }

    port {
      port        = "${var.sentinel_service_port}"
      target_port = "${data.template_file.sentinel_node_config.vars.server_port}"
    }
  }
}

resource "kubernetes_stateful_set" "redis_sentinel" {
  metadata {
    name      = "${local.sentinel_pod_name}"
    namespace = "${var.kube_namespace}"
  }

  spec {
    service_name = "${kubernetes_service.redis_sentinel.metadata.0.name}"
    replicas     = "${var.sentinel_replicas}"

    update_strategy {}

    selector {
      match_labels {
        name = "${local.sentinel_pod_name}"
      }
    }

    template {
      metadata {
        labels {
          name = "${local.sentinel_pod_name}"
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
                    values   = ["${local.sentinel_pod_name}"]
                  }
                }

                topology_key = "kubernetes.io/hostname"
              }

              weight = 100
            }
          }
        }

        # config maps are mounted as read-only and sentinel wants to be able to
        # write to it, so this init will copy the sentinel config to a writable
        # location
        init_container {
          name  = "copy-config"
          image = "busybox"

          command = ["sh", "-c", "cp /tmp/redis/sentinel.conf /tmp/writable/sentinel.conf"]

          volume_mount {
            name       = "sentinel-config"
            mount_path = "/tmp/redis"
          }

          volume_mount {
            name       = "writable-directory"
            mount_path = "/tmp/writable/"
          }
        }

        container {
          name  = "${local.sentinel_pod_name}"
          image = "${var.redis_image}"

          command = ["redis-server"]

          args = [
            "/etc/redis/sentinel.conf",
            "--sentinel",
            "--protected-mode",
            "no",
          ]

          env {
            name  = "config-file-hash"
            value = "${md5(data.template_file.sentinel_node_config.rendered)}"
          }

          port {
            container_port = "${data.template_file.sentinel_node_config.vars.server_port}"
          }

          volume_mount {
            name       = "writable-directory"
            mount_path = "/etc/redis"
          }
        }

        volume {
          name = "sentinel-config"

          config_map {
            name = "${kubernetes_config_map.sentinel_node_config.metadata.0.name}"
          }
        }

        volume {
          name      = "writable-directory"
          empty_dir = {}
        }

        image_pull_secrets {
          name = "${var.redis_image_pull_secret}"
        }
      }
    }
  }
}
