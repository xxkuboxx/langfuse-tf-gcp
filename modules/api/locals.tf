locals {
  services = toset([
    "servicenetworking.googleapis.com",
    "sql-component.googleapis.com",
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "iap.googleapis.com"
  ])
}
