terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "fit-dia-terraform-state"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

locals {
  bucket_name = "DIA-S3Bucket-${var.req_id}"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = lower(local.bucket_name)

  tags = {
    Name              = local.bucket_name
    Environment       = "Demo"
    Decommission-Date = var.decommission_date
  }
}

