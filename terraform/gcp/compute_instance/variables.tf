# Input Variables

variable "req_id" {
  type = string
}

variable "decommission_date" {
  description = "The date when the instance would be automatically deleted"
  type        = string
  default     = "2023-12-31"
}

variable "google_credentials" {
  type        = string
  description = "Path to the GCP service account key JSON file. Defaults to null to allow GOOGLE_APPLICATION_CREDENTIALS to be used in CI/CD."
  default     = null
}

