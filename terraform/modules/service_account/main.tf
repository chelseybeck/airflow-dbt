resource "google_service_account" "airflow_service_account" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Airflow Service Account"
  description  = "Service account for Airflow accessing BigQuery"
}

resource "google_project_iam_member" "bigquery_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.airflow_service_account.email}"
}

resource "google_project_iam_member" "bigquery_data_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.airflow_service_account.email}"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.airflow_service_account.email}"
}

resource "google_service_account_key" "airflow_service_account_key" {
  service_account_id = google_service_account.airflow_service_account.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"

  provisioner "local-exec" {
    command = <<EOT
      echo "${self.private_key}" | base64 --decode > ${var.key_file_path}
    EOT
  }
}

output "airflow_service_account_email" {
  value = google_service_account.airflow_service_account.email
}
