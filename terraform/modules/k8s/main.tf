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
      type = "Recreate" # Doesn't work ATM, check issue at https://github.com/terraform-providers/terraform-provider-kubernetes/issues/260
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

          env {
            name  = "PORT"
            value = 3000
          }

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
      port        = 80   # The port that will be exposed by this service.
      target_port = 3000 # Number or name of the port to access on the pods targeted by the service
    }

    type = "NodePort"
  }
}
