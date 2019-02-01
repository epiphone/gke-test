provider "kubernetes" {
  version = "1.5.0"

  host                   = "${var.host}"
  client_certificate     = "${base64decode(var.client_certificate)}"
  client_key             = "${base64decode(var.client_key)}"
  cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"
}

resource "kubernetes_deployment" "app" {
  metadata {
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
              cpu    = "0.5"
              memory = "1024Mi"
            }

            requests {
              cpu    = "0.25"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}
