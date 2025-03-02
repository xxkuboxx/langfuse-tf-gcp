# Cloud SQL (PostgreSQL) インスタンスの作成
resource "google_sql_database_instance" "default" {
  name             = "my-postgres-instance"
  database_version = "POSTGRES_16"
  settings {
    tier              = "db-f1-micro" # サンドボックスに適した最小限のtier
    availability_type = "ZONAL"       # 可用性タイプ
    ip_configuration {
      ipv4_enabled    = false            # IPv4 は無効 (プライベートIPのみ)
      private_network = var.vpc_link     # 作成したVPCネットワーク
      ssl_mode        = "ENCRYPTED_ONLY" # SSL接続を強制
    }
  }
  deletion_protection = false
}

# データベースの作成
resource "google_sql_database" "database" {
  name     = "mydb"
  instance = google_sql_database_instance.default.name
}
