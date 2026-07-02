terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "gci-techss-gcp-pjnp-01nl165115"
  region  = "us-central1"
}

# Core Resources
resource "google_compute_network" "vpc_network" {
  name                    = "pipeline-custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "pipeline-subnet-01"
  ip_cidr_range = "10.10.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_storage_bucket" "bucket" {
  name                        = "gci-techss-gcp-pjnp-01nl165115-pipeline-storage-bucket"
  location                    = "us-central1"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# Automated Permission Fixes
resource "google_project_iam_binding" "cloudbuild_deploy_operator" {
  project = "gci-techss-gcp-pjnp-01nl165115"
  role    = "roles/clouddeploy.operator"
  members = ["serviceAccount:gci-techss-gcp-pjnp-01nl165115@cloudbuild.gserviceaccount.com"]
}

# Cloud Deploy Pipeline Configuration
resource "google_clouddeploy_delivery_pipeline" "app_pipeline" {
  name        = "application-delivery-pipeline"
  location    = "us-central1"
  description = "Pipeline managed by Infra Manager"

  serial_pipeline {
    stages {
      profiles  = ["production"]
      target_id = google_clouddeploy_target.prod_target.target_id
    }
  }
}

resource "google_clouddeploy_target" "prod_target" {
  name     = "production-target"
  location = "us-central1"
  run {
    location = "projects/gci-techss-gcp-pjnp-01nl165115/locations/us-central1"
  }
}