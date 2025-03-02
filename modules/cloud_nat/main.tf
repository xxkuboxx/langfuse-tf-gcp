resource "google_compute_router" "router" {
  name    = "my-router"
  network = var.network_name
}

resource "google_compute_router_nat" "nat" {
  name                               = "langfuse-cloud-nat"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = var.subnetwork_name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
