output "redis_host" {
  value = google_redis_instance.cache.host
}

output "redis_auth_string" {
  value     = google_redis_instance.cache.auth_string
  sensitive = true # 重要: AUTH文字列を機密情報として扱う
}
