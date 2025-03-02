resource "google_compute_instance" "langfuse_worker" {
  name         = "langfuse-worker"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "projects/cos-cloud/global/images/family/cos-stable" # Container-Optimized OS
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork_name
    # 外部 IP アドレスなし
  }


  service_account {
    email  = var.cloud_run_service_account_email # 作成したサービスアカウント
    scopes = ["cloud-platform"]                  # 全ての Cloud API へのアクセス権
  }

  tags = ["langfuse-worker"]

  # 起動スクリプト
  metadata_startup_script = <<-EOT
    #!/bin/bash

    # 環境変数ファイルのディレクトリを作成
    mkdir -p /var/run/containers

    PROJECT_ID=${var.project_id}
    ACCESS_TOKEN="$(curl -s -H 'Metadata-Flavor: Google' \
    'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token' \
      | jq -r '.access_token')"
    echo "Access Token: $ACCESS_TOKEN" # デバッグ用にトークンを出力 (オプション)

    SECRET_NAME=("DATABASE_URL" "SALT" "ENCRYPTION_KEY" "LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID" "LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY")
    for SECRET in "$${SECRET_NAME[@]}"
    do
      VALUE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
      "https://secretmanager.googleapis.com/v1/projects/$PROJECT_ID/secrets/$SECRET/versions/latest:access" \
      | jq -r '.payload.data' | base64 --decode)
      echo "$SECRET:$VALUE" # 取得したシークレットを出力 (デバッグ用)
      echo "$SECRET=$VALUE" >> /var/run/containers/env.list
    done

    # 固定値の環境変数を追加
    cat >> /var/run/containers/env.list << EOF
    CLICKHOUSE_CLUSTER_ENABLED=false
    LANGFUSE_S3_EVENT_UPLOAD_REGION=auto
    LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT=https://storage.googleapis.com
    LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE=true
    LANGFUSE_S3_EVENT_UPLOAD_PREFIX=events/
    CLICKHOUSE_MIGRATION_URL=clickhouse://${var.clickhouse_ip}:9000
    CLICKHOUSE_URL=http://${var.clickhouse_ip}:8123
    CLICKHOUSE_USER=clickhouse
    CLICKHOUSE_PASSWORD=clickhouse
    REDIS_CONNECTION_STRING=redis://default:${var.redis_auth}@${var.redis_host}:6379
    LANGFUSE_S3_EVENT_UPLOAD_BUCKET=${var.langfuse_bucket_name}
    EOF

    # ファイルのパーミッションを設定
    chmod 600 /var/run/containers/env.list

    # Langfuse Workerコンテナの起動
    docker run --rm --name langfuse-worker \
      --env-file /var/run/containers/env.list \
      -p 3030:3030 \
      langfuse/langfuse-worker:3
    EOT

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }
}
