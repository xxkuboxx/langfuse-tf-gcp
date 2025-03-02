locals {
  # Cloud Run用サービスアカウントに付与するロール
  cloud_run_sa_roles = toset([
    "roles/compute.networkUser",          # Compute ネットワーク ユーザー
    "roles/cloudsql.client",              # Cloud SQL クライアント ロールの付与
    "roles/secretmanager.secretAccessor", # Secret Manager のシークレット アクセサー ロールの付与
    "roles/logging.logWriter",            # Langfuse Worker のログの確認のため
    "roles/storage.objectUser",           # トレースのGCSへの書き込み権限
  ])
}
