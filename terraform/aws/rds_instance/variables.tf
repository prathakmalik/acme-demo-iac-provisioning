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

