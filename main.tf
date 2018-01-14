provider "google" {
  project = "${var.projectid}"
  region = "${var.region}"
}

resource "google_compute_network" "network" {
  name = "${var.name}"
}

// Subnet for the BOSH director
resource "google_compute_subnetwork" "bosh-subnet-1" {
  name = "bosh-${var.name}-${var.region}"
  ip_cidr_range = "10.0.0.0/24"
  network = "${google_compute_network.network.self_link}"
}

// Allow SSH to BOSH bastion
resource "google_compute_firewall" "bosh-bastion" {
  name = "bosh-bastion-${var.name}"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = [
      "22"
    ]
  }

  target_tags = [
    "bosh-bastion"
  ]
}

// Allow open access between internal MVs
resource "google_compute_firewall" "bosh-internal" {
  name = "bosh-internal-${var.name}"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }
  target_tags = [
    "bosh-internal"
  ]
  source_tags = [
    "bosh-internal"
  ]
}

// BOSH bastion host
resource "google_compute_instance" "bosh-bastion" {
  name = "bosh-bastion-${var.name}"
  machine_type = "n1-standard-1"
  zone = "${var.zone-1}"

  tags = [
    "bosh-bastion",
    "bosh-internal"
  ]

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file("~/.ssh/google_compute_engine")}"
    timeout = "60s"
  }

  provisioner file {
    source = "cloud-config.yml"
    destination = "/tmp/cloud-config.yml"
  }

  provisioner file {
    source = "concourse.yml"
    destination = "/tmp/concourse.yml"
  }

  provisioner file {
    source = "manifest.yml.erb"
    destination = "/tmp/manifest.yml.erb"
  }

  provisioner file {
    source = "keys/bosh"
    destination = "/tmp/bosh"
  }

  provisioner file {
    source = "keys/bosh.pub"
    destination = "/tmp/bosh.pub"
  }

  provisioner remote-exec {
    inline = [
      "apt-get update -y",
      "apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3",
      "gem install bosh_cli",
      "curl -o /tmp/cf.tgz https://s3.amazonaws.com/go-cli/releases/v6.20.0/cf-cli_6.20.0_linux_x86-64.tgz",
      "tar -zxvf /tmp/cf.tgz && mv cf /usr/bin/cf && chmod +x /usr/bin/cf && rm /tmp/cf.tgz",
      "curl -o /usr/bin/bosh-init https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.96-linux-amd64",
      "chmod +x /usr/bin/bosh-init",
    ]
  }

  provisioner remote-exec {
    inline = [
      "echo project_id=\"${var.projectid}\" | sudo tee -a /etc/environment",
      "echo region=\"${var.region}\" | sudo tee -a /etc/environment",
      "echo zone=\"${var.zone-1}\" | sudo tee -a /etc/environment",
      "echo zone2=\"${var.zone-2}\" | sudo tee -a /etc/environment",
      "echo ssh_key_path=$HOME/.ssh/bosh | sudo tee -a /etc/environment",
      "echo common_password=admin | sudo tee -a /etc/environment",
      "echo atc_password=admin | sudo tee -a /etc/environment",
    ]
  }

  provisioner remote-exec {
    inline = [
      "mkdir /google-bosh-director",
      "mv /tmp/cloud-config.yml /google-bosh-director/cloud-config.yml",
      "mv /tmp/concourse.yml /google-bosh-director/concourse.yml",
      "mv /tmp/manifest.yml.erb /google-bosh-director/manifest.yml.erb",
      "mv /tmp/bosh .ssh/bosh",
      "mv /tmp/bosh.pub .ssh/bosh.pub",

      "gcloud config set compute/zone $zone",
      "gcloud config set compute/region $region",

      "cd /google-bosh-director",
      "bosh-init -v",
      "erb manifest.yml.erb > manifest.yml",
      "bosh-init deploy manifest.yml",
    ]
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-trusty-v20160627"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.bosh-subnet-1.name}"
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = [
      "cloud-platform"
    ]
  }
}

//TODO: refactor and make a dns record for the bosh bastion
//TODO: should not have external ips for anything but ATC vm
//TODO: set up SSL
//TODO: do we need the extra subnet?