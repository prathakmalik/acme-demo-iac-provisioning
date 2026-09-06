terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.1.0"
    }
  }
  backend "s3" {
    bucket = "fit-dia-terraform-state"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}

provider "google" {
  project     = "fit-dia-demo-project"
  # region      = "us-central1"
  credentials = var.google_credentials
}

locals {
  bucket_name = "DIA-GCPBucket-${var.req_id}"
  project_name = "fit-dia-demo-project"
}

resource "google_storage_bucket" "storage_bucket" {
  name = lower(local.bucket_name)
  location = "US"
  force_destroy = true
  project = local.project_name
  uniform_bucket_level_access = true

  labels = {
    name              = lower(local.bucket_name)
    environment       = "demo"
    decommission_date = lower(var.decommission_date)
  }
}

