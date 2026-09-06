# Output Variables

output "storage_bucket_details" {
  description = "Structural configuration and access metrics for the new GCP bucket"
  value = jsonencode({
    bucket_name = google_storage_bucket.storage_bucket.name
    bucket_arn  = google_storage_bucket.storage_bucket.id
    bucket_dns  = google_storage_bucket.storage_bucket.self_link
    region      = google_storage_bucket.storage_bucket.location
  })
}

# output "user_login_details" {
#   description = "GCP login details for the user"
#   value = jsonencode({
#     user_created = false
#     username     = var.requester_username
#     userarn      = ""
#     password     = null
#   })
#   sensitive = true
# }
