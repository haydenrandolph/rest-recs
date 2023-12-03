# provider.tf
terraform {
  required_version = ">= 0.14"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.50"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  # Add your authentication details here, or use environment variables
}
