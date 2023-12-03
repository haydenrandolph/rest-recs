# variables.tf
variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
  default     = "varonis-407001"
}

variable "region" {
  description = "The region where Google Cloud resources will be created"
  type        = string
  default     = "us-east1"
}

variable "docker_image_url" {
  description = "URL of the Docker image in the container registry"
  type        = string
}

resource "random_id" "bucket_suffix" {
  byte_length = 2
}
