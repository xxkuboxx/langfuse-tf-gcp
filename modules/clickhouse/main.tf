resource "google_compute_instance" "clickhouse" {
  name         = "clickhouse"
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

  tags = ["clickhouse"]

  # 起動スクリプト
  metadata_startup_script = <<-EOT
    #!/bin/bash

    # データとログ用のディレクトリを作成
    mkdir -p /home/ch_data /home/ch_logs

    # ClickHouse 設定ファイルを作成 (/home 内に作成)
    cat <<EOF > /home/docker_related_config.xml
    <clickhouse>
        <listen_host>0.0.0.0</listen_host>
        <listen_try>1</listen_try>
    </clickhouse>
    EOF

    # Docker setup
    cat <<EOF > /etc/docker/daemon.json
    {
        "storage-driver": "overlay2",
        "log-driver": "json-file",
        "log-opts": {
            "max-size": "10m",
            "max-file": "3"
        }
    }
    EOF

    systemctl daemon-reload
    systemctl restart docker

    # Clickhouseコンテナ (設定ファイルをマウント)
    docker run --rm --name clickhouse-server \
      -v /home/ch_data:/var/lib/clickhouse/ \
      -v /home/ch_logs:/var/log/clickhouse-server/ \
      -v /home/docker_related_config.xml:/etc/clickhouse-server/config.d/docker_related_config.xml \
      -e CLICKHOUSE_USER=clickhouse \
      -e CLICKHOUSE_PASSWORD=clickhouse \
      -d --ulimit nofile=262144:262144 \
      -p 8123:8123 \
      -p 9000:9000 \
      clickhouse/clickhouse-server
    EOT

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }
}
