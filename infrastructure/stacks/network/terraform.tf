terraform {
  # This is just OpenTofu's version in a suit
  required_version = "~> 1.12.0"

  # On local authenticate with:
  # gcloud auth application-default login
  backend "gcs" {
    bucket = "gke-platform-lab-tfstate"
    prefix = "state/core/network"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = "gke-platform-lab"
  region  = local.region
  zone    = local.zone

  default_labels = {
    managed_by = "tf"
  }
}
