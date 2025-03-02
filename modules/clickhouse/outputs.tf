output "clickhouse_ip" {
  value = google_compute_instance.clickhouse.network_interface.0.network_ip
}
