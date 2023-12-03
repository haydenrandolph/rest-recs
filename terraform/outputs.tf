# Example output for Cloud Run service URL
output "cloud_run_service_url" {
  value = google_cloud_run_service.api_service.status[0].url
}
