variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy the resources"
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account"
  type        = string
}

variable "key_file_path" {
  description = "The path to store the service account key file"
  type        = string
}
