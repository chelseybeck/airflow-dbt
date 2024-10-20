provider "google-beta" {
  project = var.project_id
  region  = var.region
}

module "service_account" {
  source               = "./modules/service_account"
  project_id           = var.project_id
  service_account_name = var.service_account_name
  key_file_path        = var.key_file_path
}
