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

resource "aws_instance" "ec2_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.default_security_group_id]

  tags = {
    Name              = "DIA-EC2Instance-${var.req_id}"
    Environment       = "Demo"
    Decommission-Date = var.decommission_date
  }
}

