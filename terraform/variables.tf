# variables.tf
variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}

variable "region" {
  description = "The region where Google Cloud resources will be created"
  type        = string
  default     = "us-central1"
}

variable "docker_image_url" {
  description = "URL of the Docker image in the container registry"
  type        = string
}

resource "random_id" "bucket_suffix" {
  byte_length = 2
}
