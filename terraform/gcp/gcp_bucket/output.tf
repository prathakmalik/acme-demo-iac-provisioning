# Output Variables

output "gcp_bucket_details" {
    description = "Structural configuration and access metrics for the new GCP bucket"
    value = {
        bucket_name = google_storage_bucket.s3_bucket.name
        bucket_arn  = google_storage_bucket.s3_bucket.id
        bucket_dns  = google_storage_bucket.s3_bucket.self_link
        region      = google_storage_bucket.s3_bucket.location
    }
}
