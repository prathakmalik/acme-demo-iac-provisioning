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

resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.instance_type
  db_name                = replace("demo_db_${var.req_id}", "-", "_")
  username               = "admin"
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [var.default_security_group_id]

  tags = {
    Name              = "DIA-RDSInstance-${var.req_id}"
    Environment       = "Demo"
    Decommission-Date = var.decommission_date
  }
}

