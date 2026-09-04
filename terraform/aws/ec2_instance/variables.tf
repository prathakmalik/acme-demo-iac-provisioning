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
  default     = "t3.micro"
}

variable "requester_username" {
  description = "The username of the person requesting the resource. This will be used to grant access to the S3 bucket."
  type        = string
}

variable "default_security_group_id" {
  description = "The default security group ID to associate with the instance"
  type        = string
  default     = "sg-0e0e6dec252b6d850" # FIT_DIA_SecurityGroup_All_Traffic
}

