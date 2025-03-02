resource "google_cloud_run_v2_service" "default" {
  name     = local.service_name
  location = var.region
  project  = var.project_id
  template {
    scaling {
      max_instance_count = 1
    }
    containers {
      image = "docker.io/langfuse/langfuse:3"
      ports {
        container_port = 3000 # コンテナポート
        name           = "http1"
      }

      # 環境変数
      env {
        name  = "NEXTAUTH_URL"
        value = "https://${local.service_name}-${data.google_project.project.number}.${var.region}.run.app" # エンドポイントURL
      }
      env {
        name  = "CLICKHOUSE_CLUSTER_ENABLED"
        value = "false"
      }
      env {
        name  = "CLICKHOUSE_URL"
        value = "http://${var.clickhouse_ip}:8123"
      }
      env {
        name  = "CLICKHOUSE_MIGRATION_URL"
        value = "clickhouse://${var.clickhouse_ip}:9000"
      }
      env {
        name  = "CLICKHOUSE_USER"
        value = "clickhouse"
      }
      env {
        name  = "CLICKHOUSE_PASSWORD"
        value = "clickhouse"
      }
      env {
        name  = "LANGFUSE_S3_EVENT_UPLOAD_REGION"
        value = "auto"
      }
      env {
        name  = "LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT"
        value = "https://storage.googleapis.com"
      }
      env {
        name  = "LANGFUSE_S3_EVENT_UPLOAD_PREFIX"
        value = "events/"
      }
      env {
        name  = "LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE"
        value = "true"
      }
      env {
        name  = "LANGFUSE_S3_EVENT_UPLOAD_BUCKET"
        value = var.langfuse_bucket_name
      }
      env {
        name  = "REDIS_CONNECTION_STRING"
        value = "redis://default:${var.redis_auth}@${var.redis_host}:6379"
      }

      # シークレット
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = var.database_url_secret_id # Secret Manager のシークレット
            version = "latest"                   # 最新バージョン
          }
        }
      }
      env {
        name = "NEXTAUTH_SECRET"
        value_source {
          secret_key_ref {
            secret  = var.nextauth_secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "SALT"
        value_source {
          secret_key_ref {
            secret  = var.salt_secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "ENCRYPTION_KEY"
        value_source {
          secret_key_ref {
            secret  = var.encryption_key_id
            version = "latest"
          }
        }
      }
      env {
        name = "LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID"
        value_source {
          secret_key_ref {
            secret  = var.hmac_id
            version = "latest"
          }
        }
      }
      env {
        name = "LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY"
        value_source {
          secret_key_ref {
            secret  = var.hmac_secret_id
            version = "latest"
          }
        }
      }

      resources {
        limits = {
          memory = "1Gi"
          cpu    = "1"
        }
      }
      # Cloud SQL への接続設定 (containers ブロック内)
      volume_mounts {
        mount_path = "/cloudsql"
        name       = "cloudsql"
      }
    }
    service_account = var.cloud_run_service_account_email # 作成したサービスアカウント

    # Direct VPC Egress の設定
    vpc_access {
      # connector は指定しない
      egress = "PRIVATE_RANGES_ONLY" # プライベートIPへのトラフィックのみ

      network_interfaces {
        network    = var.network_name    # VPC ネットワーク名
        subnetwork = var.subnetwork_name # サブネットワーク名
        tags       = ["cloud-run"]       # (オプション) ネットワークタグ
      }
    }

    # Cloud SQL への接続設定 (template ブロック内)
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.connection_name]
      }
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST" # 最新のリビジョンに 100% のトラフィックをルーティング
  }

}
