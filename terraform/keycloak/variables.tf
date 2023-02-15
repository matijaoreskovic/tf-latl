variable "gke_namespace" {
  default = "learn-at-lunch"
  type = string
  description = "Kubernetes namespace"
}

variable "keycloak_password" {
  default = ""
  type = string
  description = "Password fo keycloak admin user"
}

variable "keycloak_url" {
  default = "localhost"
  type = string
}