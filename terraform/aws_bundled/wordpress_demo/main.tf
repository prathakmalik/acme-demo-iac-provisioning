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
  bucket_name       = "DIA-S3Bucket-${var.req_id}"
  ec2_instance_name = "DIA-EC2Instance-${var.req_id}"
  db_instance_name  = "DIA-RDSInstance-${var.req_id}"
  sg_name           = "DIA-SG-${var.req_id}"
  lb_name           = "DIA-LB-${var.req_id}"

  common_tags = {
    Environment       = "Demo"
    Decommission-Date = var.decommission_date
  }
}

# S3 Bucket Resource
resource "aws_s3_bucket" "s3_bucket" {
  bucket = lower(local.bucket_name)

  tags = merge(local.common_tags, {
    Name = local.bucket_name
  })
}

# EC2 Instance Resource
resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.ec2_instance_type

  tags = merge(local.common_tags, {
    Name = local.ec2_instance_name
  })
}

# DB Instance Resource
resource "aws_db_instance" "rds_instance" {
  allocated_storage   = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = var.db_instance_type
  db_name             = lower(replace(local.db_instance_name, "-", "_"))
  username            = "admin"
  password            = var.db_password
  skip_final_snapshot = true

  tags = merge(local.common_tags, {
    Name = local.db_instance_name
  })
}

# Security Group Resource
resource "aws_security_group" "demo_sg" {
  name        = local.sg_name
  description = "Security group for the demo application"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# # Create the VPC first
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }



############################# CREATE Load Balancer is Unavailable######################################
# │ Error: creating ELBv2 network Load Balancer (DIA-LB-REQ-12345): operation error Elastic Load Balancing v2: CreateLoadBalancer, 
#   https response error StatusCode: 400, RequestID: 12488e6f-66b2-4a59-aa1e-934674497708, 
#   OperationNotPermitted: This AWS account currently does not support creating load balancers. 
#   For more information, please contact AWS Support.


# data "aws_vpc" "default" {
#   id = var.vpc_id
# }

# data "aws_subnets" "default_subnets" {
#   filter {
#     name   = "vpc-id"
#     values = [var.vpc_id]
#   }
# }

# # Load Balancer Resource
# resource "aws_lb" "demo_lb" {
#   name               = local.lb_name
#   internal           = false     # Set to true if it is an internal corporate LB
#   load_balancer_type = "network" # Use "application" for HTTP/HTTPS LB
#   security_groups    = [aws_security_group.demo_sg.id]
#   subnets            = [for subnet in data.aws_subnets.default_subnets.ids : subnet]

#   tags = merge(local.common_tags, {
#     Name = local.lb_name
#   })
# }

