# 出力 (サービスアカウントのメールアドレス)
output "cloud_run_service_account_email" {
  value = google_service_account.cloud_run_service_account.email
}
