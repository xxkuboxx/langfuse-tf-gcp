resource "google_compute_firewall" "allow_langfuse" {
  name        = "allow-langfuse"
  network     = var.network_name
  target_tags = ["langfuse-worker"]

  allow {
    protocol = "tcp"
    ports    = ["3030"]
  }

  source_ranges = [var.subnetwork_ip_cidr_range]
}

resource "google_compute_firewall" "allow_clickhouse" {
  name        = "allow-clickhouse"
  network     = var.network_name
  target_tags = ["clickhouse"]

  allow {
    protocol = "tcp"
    ports    = ["8123", "9000"]
  }

  source_ranges = [var.subnetwork_ip_cidr_range]
}

resource "google_compute_firewall" "allow_health_check" {
  name        = "allow-health-check"
  network     = var.network_name
  target_tags = ["clickhouse"]

  allow {
    protocol = "tcp"
    ports    = ["8123"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

resource "google_compute_firewall" "allow_rdp_ingress_from_iap" {
  name        = "allow-rdp-ingress-from-iap"
  network     = var.network_name
  description = "Allows RDP ingress from IAP"
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["clickhouse", "langfuse-worker"]
}

resource "google_compute_firewall" "allow_ssh_ingress_from_iap" {
  name        = "allow-ssh-ingress-from-iap"
  network     = var.network_name
  description = "Allows SSH ingress from IAP"
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["clickhouse", "langfuse-worker"]
}
