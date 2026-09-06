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
  ec2_instance_name = "DIA-EC2Instance-${var.req_id}"
  db_instance_name  = "DIA-RDSInstance-${var.req_id}"
  sg_name           = "DIA-SG-${var.req_id}"
  lb_name           = "DIA-LB-${var.req_id}"

  common_tags = {
    Environment       = "Demo"
    Decommission-Date = var.decommission_date
  }
}

# S3 Bucket Resource module
module "s3_bucket" {
  source = "../../aws/s3_bucket"
  req_id             = var.req_id
  decommission_date  = var.decommission_date
  requester_username = var.requester_username
}

# EC2 Instance Resource module
module "compute_instance" {
  source = "../../aws/ec2_instance"
  req_id             = var.req_id
  decommission_date  = var.decommission_date
  ami_id             = var.ami_id
  instance_type      = var.ec2_instance_type
  default_security_group_id = var.default_security_group_id
  requester_username = var.requester_username
}

# DB Instance Resource mdodule
module "db_instance" {
  source = "../../aws/rds_instance"
  req_id             = var.req_id
  decommission_date  = var.decommission_date
  instance_type      = var.db_instance_type
  default_security_group_id = var.default_security_group_id
  db_password        = var.db_password
  requester_username = var.requester_username
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



############################# CREATE Load Balancer is Unavailable ######################################
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

