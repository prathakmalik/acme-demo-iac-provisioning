# Input Variables

variable "req_id" {
  type = string
}

variable "decommission_date" {
  description = "The date when the instance would be automatically deleted"
  type        = string
  default     = "2023-12-31"
}

variable "requester_username" {
  description = "The username of the person requesting the resource. This will be used to grant access to the S3 bucket."
  type        = string
}

