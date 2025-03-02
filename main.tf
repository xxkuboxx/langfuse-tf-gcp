terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}

module "api" {
  source = "./modules/api"
}

module "vpc" {
  source     = "./modules/vpc"
  depends_on = [module.api]
}

module "vpc_peering" {
  source     = "./modules/vpc_peering"
  vpc_link   = module.vpc.link
  depends_on = [module.api]
}

module "cloud_sql" {
  source     = "./modules/cloud_sql"
  vpc_link   = module.vpc.link
  depends_on = [module.api, module.vpc_peering]
}

module "secret_manager" {
  source     = "./modules/secret_manager"
  depends_on = [module.api]
}

module "service_account" {
  source     = "./modules/service_account"
  project_id = local.project_id
  depends_on = [module.api]
}

module "firewall" {
  source                   = "./modules/firewall"
  network_name             = module.vpc.network_name
  subnetwork_name          = module.vpc.subnetwork_name
  subnetwork_ip_cidr_range = module.vpc.subnetwork_ip_cidr_range
  depends_on               = [module.api]
}

module "redis" {
  source                        = "./modules/redis"
  vpc_link                      = module.vpc.link
  google_managed_services_range = module.vpc_peering.google_managed_services_range
  depends_on                    = [module.api, module.vpc_peering]
}

module "storage" {
  source     = "./modules/storage"
  project_id = local.project_id
  region     = local.region
  depends_on = [module.api]
}

module "cloud_nat" {
  source          = "./modules/cloud_nat"
  network_name    = module.vpc.network_name
  subnetwork_name = module.vpc.subnetwork_name
  depends_on      = [module.api]
}

module "clickhouse" {
  source                          = "./modules/clickhouse"
  network_name                    = module.vpc.network_name
  subnetwork_name                 = module.vpc.subnetwork_name
  cloud_run_service_account_email = module.service_account.cloud_run_service_account_email
  region                          = local.region
  depends_on                      = [module.api]
}

module "langfuse_worker" {
  source                          = "./modules/langfuse_worker"
  project_id                      = local.project_id
  region                          = local.region
  network_name                    = module.vpc.network_name
  subnetwork_name                 = module.vpc.subnetwork_name
  cloud_run_service_account_email = module.service_account.cloud_run_service_account_email
  clickhouse_ip                   = module.clickhouse.clickhouse_ip
  langfuse_bucket_name            = module.storage.langfuse_bucket_name
  redis_auth                      = module.redis.redis_auth_string
  redis_host                      = module.redis.redis_host
  depends_on                      = [module.api, module.cloud_sql, module.clickhouse]
}

module "langfuse_web" {
  source                          = "./modules/langfuse_web"
  project_id                      = local.project_id
  region                          = local.region
  database_url_secret_id          = module.secret_manager.database_url_secret_id
  nextauth_secret_id              = module.secret_manager.nextauth_secret_id
  salt_secret_id                  = module.secret_manager.salt_secret_id
  encryption_key_id               = module.secret_manager.encryption_key_id
  hmac_id                         = module.secret_manager.hmac_id
  hmac_secret_id                  = module.secret_manager.hmac_secret_id
  cloud_run_service_account_email = module.service_account.cloud_run_service_account_email
  network_name                    = module.vpc.network_name
  subnetwork_name                 = module.vpc.subnetwork_name
  connection_name                 = module.cloud_sql.connection_name
  clickhouse_ip                   = module.clickhouse.clickhouse_ip
  langfuse_bucket_name            = module.storage.langfuse_bucket_name
  redis_auth                      = module.redis.redis_auth_string
  redis_host                      = module.redis.redis_host
  depends_on                      = [module.api, module.cloud_sql, module.clickhouse, module.langfuse_worker]
}
