resource "random_id" "service_suffix" {
  byte_length = 2
}


# Cloud Run Service - provisions service that runs container
resource "google_cloud_run_service" "api_service" {
  name     = "rest-rec-service-${random_id.service_suffix.hex}"
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
  name     = "rest-rec-logs-${random_id.service_suffix.hex}"
  location = var.region
}