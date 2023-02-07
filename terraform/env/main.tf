
terraform {
  required_version = ">=1"

  backend "gcs" {
    bucket = "tf-state-learn-at-lunch"
    prefix = "very-secret-folder"
  }
}

module "kuberentes" {
  source = "../mod/kubernetes"
}

output "lb-access-ip" {
  value = module.kuberentes.lb-ip
}

