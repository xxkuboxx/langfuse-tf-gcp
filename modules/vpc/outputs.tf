output "link" {
  value = google_compute_network.default.self_link
}

output "network_name" {
  value = google_compute_network.default.name
}

output "subnet_link" {
  value = google_compute_subnetwork.subnet_1.self_link
}

output "subnetwork_name" {
  value = google_compute_subnetwork.subnet_1.name
}

output "subnetwork_ip_cidr_range" {
  value = google_compute_subnetwork.subnet_1.ip_cidr_range
}
