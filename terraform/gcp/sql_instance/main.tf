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
  credentials = file("C:/Users/prath/Downloads/fit-dia-demo-project-cec7efb55152.json")
}

locals {
  db_name = lower("DIA-GCPDBInstance-${var.req_id}")
  project_name = "fit-dia-demo-project"
}

resource "google_sql_database_instance" "sql_instance" {
  name             = local.db_name
  database_version = "MYSQL_8_0"
  region           = "us-central1"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    user_labels = {
      name              = local.db_name
      environment       = "demo"
      decommission_date = lower(var.decommission_date)
    }
  }
}

