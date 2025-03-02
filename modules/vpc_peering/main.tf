# プライベートサービス接続用のIPアドレス範囲の割り当て
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_link
}

# サービスネットワーキング接続の作成
resource "google_service_networking_connection" "private_service_access" {
  network                 = var.vpc_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
