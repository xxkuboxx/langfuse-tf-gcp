# VPCネットワークの作成
resource "google_compute_network" "default" {
  name                    = "my-vpc" # VPCネットワークの名前
  auto_create_subnetworks = false    # サブネットを自動作成しない場合はfalse
}

# サブネットの作成 (必要に応じて複数作成)
resource "google_compute_subnetwork" "subnet_1" {
  name                     = "my-subnet"
  ip_cidr_range            = "10.0.0.0/24" # サブネットのCIDR範囲
  network                  = google_compute_network.default.self_link
  private_ip_google_access = true
}
