# outputs.tf
output "function_url" {
  value     = google_cloudfunctions_function.docker_function.https_trigger_url
  description = "The URL of the deployed Cloud Function"
  sensitive = false
}
