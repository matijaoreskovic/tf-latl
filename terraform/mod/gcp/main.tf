resource "random_password" "random_pwd" {
  length = 36
  special = false
  min_upper = 6
  min_numeric = 15
}

resource "tls_private_key" "ssh_key" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

locals {
  randomPwd = sensitive(random_password.random_pwd.result)
}

resource "google_compute_firewall" "default" {
  depends_on = [
    google_compute_instance.test
  ]
  name    = "latl-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "8080", "8443"]
  }
  target_tags = [ "latl" ]
  source_ranges = [ "0.0.0.0/0" ]
  direction = "INGRESS"
}


resource "google_compute_instance" "test" {
  timeouts {
    create = "5m"
    delete = "3m"
    update = "5m"
  }

  name         = "latl-test"
  machine_type = "e2-medium"
  zone         = "europe-west3-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
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

  tags = ["latl"]

  metadata = {
    ssh-keys = "terraform:${trimspace(tls_private_key.ssh_key.public_key_openssh)}"
  }

  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model = "SPOT"
  }

  connection {
      host = google_compute_instance.test.network_interface.0.access_config.0.nat_ip
      type = "ssh"
      user = "terraform"
      agent = "false"
      private_key = trimspace(tls_private_key.ssh_key.private_key_openssh)
    }

  provisioner "remote-exec" {
    script = "${path.module}/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/terraform/keycloak-16.0.0/bin/",
      "sudo ./add-user-keycloak.sh --realm master --user admin --password ${local.randomPwd}",
      "sudo nohup ./standalone.sh -b 0.0.0.0 > /dev/null 2>&1 &",
      "sleep 20",
      "sudo ./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password ${local.randomPwd}",
      "sudo ./kcadm.sh update realms/master -s sslRequired=NONE"
    ]
  }
}

output "out_randomPwd" {
  value     = local.randomPwd
  sensitive = true
}

output "out_extIp" {
  value     = google_compute_instance.test.network_interface.0.access_config.0.nat_ip
  description = "External IP address of VM"
}