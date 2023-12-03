resource "google_cloudfunctions_function" "docker_function" {
  name        = "rest-rec-function"
  description = "Service to recommend restaurants"
  runtime     = "nodejs14"

  available_memory_mb = 256
  entry_point         = "app"
  labels = {
    deployment-tool = "terraform"
  }
  source_repository {
    url = var.docker_image_url
  }

  trigger_http = true
}

resource "google_cloudfunctions_function_iam_binding" "function_invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.docker_function.name

  role    = "roles/cloudfunctions.invoker"
  members = ["allUsers"]
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
