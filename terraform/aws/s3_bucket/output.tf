# Output Variables

output "s3_bucket_details" {
    description = "Structural configuration and access metrics for the new S3 bucket"
    value = jsonencode({
        bucket_name = aws_s3_bucket.s3_bucket.id
        bucket_arn  = aws_s3_bucket.s3_bucket.arn
        bucket_dns  = aws_s3_bucket.s3_bucket.bucket_domain_name
        region      = aws_s3_bucket.s3_bucket.region
    })
}

output "user_login_details" {
    description = "AWS login details for the user"
    value       = jsonencode(module.iam_user.user_login_details)
    sensitive   = true
}

