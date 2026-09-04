# Input Variables

variable "req_id" {
  type = string
}

variable "decommission_date" {
  description = "The date when the instance would be automatically deleted"
  type        = string
  default     = "2023-12-31"
}

variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
  default = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" # Amazon Linux 2 AMI
}

variable "ec2_instance_type" {
  description = "The type of EC2 instance to start"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_type" {
  description = "The type of DB instance to start"
  type        = string
  default     = "db.t3.micro"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
  default     = "vpc-040f74b246a0e6155"
}

variable "requester_username" {
  description = "The username of the person requesting the resource. This will be used to grant access to the S3 bucket."
  type        = string
}
