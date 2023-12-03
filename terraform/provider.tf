terraform {
  required_version = ">= 0.14"

  cloud {
    organization = "haydenrandolph1"

    workspaces {
      name = "rest-recs"
    }
  }

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
}
