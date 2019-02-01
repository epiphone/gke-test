provider "kubernetes" {
  version = "1.5.0"

  host                   = "${var.host}"
  client_certificate     = "${base64decode(var.client_certificate)}"
  client_key             = "${base64decode(var.client_key)}"
  cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"
}

resource "kubernetes_deployment" "app" {
  metadata {
    generate_name = "app-"

    labels {
      test = "app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        test = "app"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update = {
        max_surge       = 0
        max_unavailable = "100%"
      }
    }

    # Describes the pod that will be created if insufficient replicas are detected:
    template {
      metadata {
        labels {
          test = "app"
        }
      }

      spec {
        container {
          image = "${var.app_image}"
          name  = "app"

          port {
            container_port = 3000
          }

          resources {
            limits {
              cpu    = "500m"
              memory = "1024Mi"
            }

            requests {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    generate_name = "app-"
  }

  spec {
    selector {
      test = "${kubernetes_deployment.app.metadata.0.labels.test}"
    }

    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = "${kubernetes_deployment.app.spec.template.spec.container.container_port}"
    }

    type = "LoadBalancer"
  }
}
