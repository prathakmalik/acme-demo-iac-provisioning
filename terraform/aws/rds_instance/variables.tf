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

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "db.t3.micro"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

