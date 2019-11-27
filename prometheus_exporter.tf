resource "kubernetes_service" "redis_exporter" {
  count = "${var.include_prometheus_exporter ? 1 : 0}"

  metadata {
    name      = "redis-exporter"
    namespace = "${var.kube_namespace}"

    annotations {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = 9121
      "prometheus.io/path"   = "/metrics"
    }
  }

  spec {
    type = "ClusterIP"

    selector {
      name = "redis-exporter"
    }

    port {
      port        = 9121
      target_port = 9121
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_deployment" "redis-exporter" {
  count = "${var.include_prometheus_exporter ? 1 : 0}"

  metadata {
    name      = "redis-exporter"
    namespace = "${var.kube_namespace}"
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        name = "redis-exporter"
      }
    }

    template {
      metadata {
        labels {
          name = "redis-exporter"
        }
      }

      spec {
        container {
          name  = "redis-exporter"
          image = "oliver006/redis_exporter:latest"

          port {
            container_port = 9121
            protocol       = "TCP"
          }

          resources {
            requests {
              cpu    = "100m"
              memory = "100Mi"
            }

            limits {
              cpu    = "300m"
              memory = "300Mi"
            }
          }

          env {
            name  = "REDIS_ADDR"
            value = "redis://${kubernetes_deployment.redis_master.metadata.0.name}:${kubernetes_service.redis_master.spec.0.port.0.port}"
          }

          env {
            name  = "REDIS_PASSWORD"
            value = "${var.redis_auth}"
          }
        }
      }
    }
  }
}
