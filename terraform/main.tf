//service account for cloud run & attach logging permissions
resource "google_service_account" "cloud_run_service_account" {
  account_id   = "rest-rec-service-account"
  display_name = "Cloud Run Service Account"
}

resource "google_project_iam_binding" "run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]
}

resource "google_project_iam_binding" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]
}

# Cloud Run Service - provisions service that runs container
resource "google_cloud_run_service" "api_service" {
  name     = "rest-rec-service"
  location = var.region
  template {
    spec {
      containers {
        image = var.docker_image_url
      }
      service_account_name = google_service_account.cloud_run_service_account.email
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allow unauthenticated invocations
resource "google_cloud_run_service_iam_policy" "api_service_policy" {
  location    = google_cloud_run_service.api_service.location
  project     = var.project_id
  service     = google_cloud_run_service.api_service.name

  policy_data = <<EOF
  {
    "bindings": [{
      "role": "roles/run.invoker",
      "members": [
        "allUsers"
      ]
    }]
  }
  EOF
}

# Bucket to capture logs
resource "google_storage_bucket" "log_bucket" {
  name     = "rest-rec-logs"
  location = var.region
}

# send logs from service to bucket for retention
resource "google_logging_project_sink" "cloud_run_sink" {
  name                   = "cloud-run-log-sink"
  destination            = "storage.googleapis.com/${google_storage_bucket.log_bucket.name}"
  filter                 = "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${google_cloud_run_service.api_service.name}\""
  unique_writer_identity = true
}

resource "google_storage_bucket_iam_binding" "log_bucket_writer" {
  bucket = google_storage_bucket.log_bucket.name
  role   = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.cloud_run_sink.writer_identity,
  ]
}
