
terraform {
  required_version = ">=1"

  backend "gcs" {
    bucket = "tf-state-learn-at-lunch"
    prefix = "very-secret-folder"
  }
    required_providers {
    google = {
      source  = "google"
      version = ">=4.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7"
    }
  }
}

provider "google" {
  project = "ag04-workshop"
  region  = "europe-west3"
  # (alternative) credentials   = "/path/to/key.json"
  # (alternative) access_token  = "oauth-token"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "kuberentes" {
  source = "../../mod/kubernetes"
    depends_on = [
    module.gcp
  ]
}

output "lb-access-ip" {
  value = module.kuberentes.lb-ip
}

module "gcp" {
  source = "../../mod/gcp"
}