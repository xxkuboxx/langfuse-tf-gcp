resource "google_redis_instance" "cache" {
  name                    = "langfuse-redis" # インスタンス名 (必要に応じて変更)
  tier                    = "BASIC"
  memory_size_gb          = 1
  authorized_network      = var.vpc_link
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  auth_enabled            = true
  transit_encryption_mode = "DISABLED"
  redis_version           = "REDIS_7_0"
  reserved_ip_range       = var.google_managed_services_range
  display_name            = "Langfuse Redis Instance"
  redis_configs = {
    "maxmemory-policy" = "noeviction"
  }
}
