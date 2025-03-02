# Cloud Run用サービスアカウントの作成
resource "google_service_account" "cloud_run_service_account" {
  account_id   = "cloud-run-sa" # サービスアカウントID (プロジェクト内で一意)
  display_name = "Service Account for Cloud Run"
  description  = "Custom service account for Cloud Run with specific permissions"
}

# Cloud Run用サービスアカウントにロール付与
resource "google_project_iam_member" "compute_network_user" {
  project  = var.project_id
  for_each = local.cloud_run_sa_roles
  role     = each.value
  member   = "serviceAccount:${google_service_account.cloud_run_service_account.email}"
}
