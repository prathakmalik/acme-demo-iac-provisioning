# Output Variables

output "s3_bucket_details" {
    description = "Structural configuration and access metrics for the new S3 bucket"
    value = {
        bucket_name = aws_s3_bucket.s3_bucket.id
        bucket_arn  = aws_s3_bucket.s3_bucket.arn
        bucket_dns  = aws_s3_bucket.s3_bucket.bucket_domain_name
        region      = aws_s3_bucket.s3_bucket.region
    }
}

