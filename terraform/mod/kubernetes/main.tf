resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "learn-at-lunch"
  }
}

resource "random_pet" "random_animal" {
  length = 1
}

resource "kubernetes_secret" "secrets" {
    depends_on = [
      kubernetes_namespace.namespace
    ]
    metadata {
      name = "web-secret"
      namespace = var.gke_namespace
    }
    data = {
      "very_secret_animal" = random_pet.random_animal.id
    }
}

data "google_compute_instance" "gcp-vm-instance" {
  name = "latl-test"
  zone = "europe-west3-c"
}

resource "kubernetes_deployment" "web" {
  depends_on = [
    kubernetes_secret.secrets
  ]
  timeouts {
    create = "2m"
    update = "1m"
  }
  metadata {
    namespace = var.gke_namespace
    name      = "simple-web-notch"
    labels = {
        "used_for" : "learn-at-lunch"
    }
  }
  spec {
    replicas = 1
    strategy {
      type = "RollingUpdate"
    }

    selector {
      match_labels = {
        "used_for" : "learn-at-lunch"
      }
    }
    template {
            metadata {
        labels = {
          "used_for" : "learn-at-lunch"
        }
      }
      spec {
        restart_policy = "Always"
        node_selector = {
          "cloud.google.com/gke-nodepool" : "default-pool"
        }
        container {
          image = "moreskovic/simple-web-notch:latest"
          name  = "simple-web-notch"
          env {
            name = "SECRET_VARIABLE"
            value_from {
              secret_key_ref {
                name = "web-secret"
                key  = "very_secret_animal"
              }
            }
          }
          env {
            name = "VARIABLE_FROM_DATA"
            value = data.google_compute_instance.gcp-vm-instance.boot_disk.0.initialize_params.0.image
          }
          port {
            container_port = 80
            name           = "http"
            protocol       = "TCP"
          }
          resources {
            limits = {
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "web_lb" {
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_deployment.web
  ]
  timeouts {
    create = "3m"
  }
  metadata {
    namespace = var.gke_namespace
    name      = "simple-web-notch-lb"
  }
  spec {
    selector = {
      "used_for": "learn-at-lunch"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

output "lb-ip" {
  value = kubernetes_service.web_lb.status.0.load_balancer.0.ingress.0.ip
}