terraform {
  required_version = ">=1"

  backend "gcs" {
    bucket = "tf-state-learn-at-lunch"
    prefix = "very-secret-folder/keycloak"
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 3.9.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "kubernetes_secret" "keycloak-credentials" {
  metadata {
    name      = "web-secret"
    namespace = var.gke_namespace
  }
}

locals {
  keycloak_url      = data.kubernetes_secret.keycloak-credentials.data.keycloak_url
  keycloak_password = data.kubernetes_secret.keycloak-credentials.data.keycloak_password
  
  init_password     = "T3st1ngPa$$word!"
  users = csvdecode(file("${path.module}/users.csv"))
}


provider "keycloak" {
  client_id     = "admin-cli"
  username      = "admin"
  password      = local.keycloak_password
  url           = local.keycloak_url
  initial_login = false
}


data "keycloak_realm" "keycloak-realm-info" {
  realm = "master"
}


resource "keycloak_user" "test-users" {
  for_each = { for user in local.users : user.id => user}

  realm_id   = data.keycloak_realm.keycloak-realm-info.id
  username   = each.value.username
  first_name = each.value.first_name
  last_name  = each.value.last_name
  enabled    = true
  email      = each.value.email

  attributes = {
    "locale"    = "en"
  }

  initial_password {
    value     = local.init_password
    temporary = false
  }
}
