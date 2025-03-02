output "database_url_secret_id" {
  value = google_secret_manager_secret.database_url_secret.secret_id
}

output "nextauth_secret_id" {
  value = google_secret_manager_secret.nextauth_secret.secret_id
}

output "salt_secret_id" {
  value = google_secret_manager_secret.salt_secret.secret_id
}

output "encryption_key_id" {
  value = google_secret_manager_secret.encryption_key.secret_id
}

output "hmac_id" {
  value = google_secret_manager_secret.hmac.secret_id
}

output "hmac_secret_id" {
  value = google_secret_manager_secret.hmac_secret.secret_id
}
