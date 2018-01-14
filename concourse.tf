resource "google_compute_subnetwork" "concourse-public-subnet-1" {
  name = "concourse-public-${var.region}-1"
  ip_cidr_range = "10.150.0.0/16"
  network = "${google_compute_network.network.self_link}"
}

resource "google_compute_subnetwork" "concourse-public-subnet-2" {
  name = "concourse-public-${var.region}-2"
  ip_cidr_range = "10.160.0.0/16"
  network = "${google_compute_network.network.self_link}"
}

resource "google_dns_managed_zone" "thomasshoulerio" {
  name = "thomasshoulerio"
  dns_name = "thomasshouler.io."
  description = "thomasshouler.io"
  name_servers = [
    "ns-cloud-e1.googledomains.com",
    "ns-cloud-e2.googledomains.com",
    "ns-cloud-e3.googledomains.com",
    "ns-cloud-e4.googledomains.com",
  ]
}

resource "google_dns_record_set" "concourse" {
  name = "concourse.${google_dns_managed_zone.thomasshoulerio.dns_name}"
  type = "A"
  ttl = 300
  managed_zone = "${google_dns_managed_zone.thomasshoulerio.name}"
  rrdatas = [
    "${google_compute_address.concourse.address}"
  ]
}

resource "google_compute_firewall" "concourse-public" {
  name = "concourse-public"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports = [
      "80",
      "8080",
      "443",
      "4443"
    ]
  }
  source_ranges = [
    "0.0.0.0/0"
  ]

  target_tags = [
    "concourse-public"
  ]
}

resource "google_compute_firewall" "concourse-internal" {
  name = "concourse-internal"
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
    "concourse-internal",
    "bosh-internal"
  ]
  source_tags = [
    "concourse-internal",
    "bosh-internal"
  ]
}

resource "google_compute_address" "concourse" {
  name = "concourse"
}
