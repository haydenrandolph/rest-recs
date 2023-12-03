# Cloud Run Service - provisions service that runs container
resource "google_cloud_run_service" "api_service" {
  name     = "rest-rec-service"
  location = var.region
  template {
    spec {
      containers {
        image = var.docker_image_url
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# allow unauthenticated invocations
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

//bucket to capture logs
resource "google_storage_bucket" "log_bucket" {
  name     = "rest-rec-logs-${random_id.bucket_suffix.hex}"
  location = var.region
}

resource "google_logging_project_sink" "log_sink" {
  name                   = "rest-rec-log-sink"
  destination            = "storage.googleapis.com/${google_storage_bucket.log_bucket.name}"
  filter                 = "resource.type = \"cloud_function\" AND resource.labels.function_name = \"${google_cloudfunctions_function.docker_function.name}\""
  unique_writer_identity = true
}

resource "google_storage_bucket_iam_binding" "log_bucket_writer" {
  bucket = google_storage_bucket.log_bucket.name
  role   = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.log_sink.writer_identity,
  ]
}
