# Input Variables

variable "req_id" {
  type = string
}

variable "decommission_date" {
  description = "The date when the instance would be automatically deleted"
  type        = string
  default     = "2023-12-31"
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

variable "requester_username" {
  description = "The username of the person requesting the resource. This will be used to grant access to the S3 bucket."
  type        = string
}

variable "default_security_group_id" {
  description = "The default security group ID to associate with the instance"
  type        = string
  default     = "sg-0e0e6dec252b6d850" # FIT_DIA_SecurityGroup_All_Traffic
}

