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
  }
}

provider "google" {
  project = "ag04-workshop"
  region  = "europe-west3"
  }

resource "google_compute_instance" "test" {
  name         = "latl-test"
  machine_type = "e2-micro"
  zone         = "europe-west3-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      labels = {
        purpose = "latl"
      }
      size = 10
    }
  }
  network_interface {
    network = "default"
    access_config {
      network_tier = "STANDARD"
    }    
  }
  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model = "SPOT"
  }
}

