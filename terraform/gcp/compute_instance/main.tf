terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.1.0"
    }
  }
  backend "s3" {
    bucket       = "fit-dia-terraform-state"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "google" {
  project = "fit-dia-demo-project"
  # region      = "us-central1"
  credentials = var.google_credentials
}

locals {
  instance_name = lower("DIA-GCPComputeInstance-${var.req_id}")
  machine_type  = "e2-micro"
  project_name  = "fit-dia-demo-project"
  zone          = "us-central1-a"
}

# 1. Enable the Compute Engine API
# resource "google_project_service" "compute_api" {
#   project            = local.project_name
#   service            = "compute.googleapis.com"
#   disable_on_destroy = false # Keeps the API enabled if you destroy the instance later
# }

resource "google_compute_instance" "demo_instance" {
  # depends_on = [google_project_service.compute_api]

  name         = local.instance_name
  machine_type = local.machine_type
  zone         = local.zone
  project      = local.project_name

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral public IP
    }
  }

  # --- Enable OS Login ---
  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = {
    environment       = "demo"
    env_id            = lower(var.req_id)
    decommission_date = lower(var.decommission_date)
    managed_by        = "workato-demo-automation"
  }
}

