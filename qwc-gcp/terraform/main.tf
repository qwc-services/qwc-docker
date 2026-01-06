terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 6.22.0"
    }
    google-beta= {
      source = "hashicorp/google-beta"
      version = "~> 6.22.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }
  required_version = ">= 0.14.0"
  backend "gcs" {}
}

provider "google" {
  project = var.project-name
  region  = var.region
}

data "google_project" "project" {
  project_id = var.project-name
}

provider "postgresql" {
}