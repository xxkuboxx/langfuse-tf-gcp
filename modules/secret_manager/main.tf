# 1. DATABASE_URL シークレットの作成
resource "google_secret_manager_secret" "database_url_secret" {
  secret_id = "DATABASE_URL" # Secret ID
  replication {
    auto {}
  }
}

# NEXTAUTH_SECRET シークレットの作成
resource "google_secret_manager_secret" "nextauth_secret" {
  secret_id = "NEXTAUTH_SECRET"
  replication {
    auto {}
  }
}

# SALT シークレットの作成
resource "google_secret_manager_secret" "salt_secret" {
  secret_id = "SALT"
  replication {
    auto {}
  }
}

# encryption_key シークレットの作成
resource "google_secret_manager_secret" "encryption_key" {
  secret_id = "ENCRYPTION_KEY"
  replication {
    auto {}
  }
}

# hmac シークレットの作成
resource "google_secret_manager_secret" "hmac" {
  secret_id = "LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID"
  replication {
    auto {}
  }
}

# hmac_secret シークレットの作成
resource "google_secret_manager_secret" "hmac_secret" {
  secret_id = "LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY"
  replication {
    auto {}
  }
}
