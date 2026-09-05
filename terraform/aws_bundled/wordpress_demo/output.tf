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

output "ec2_instance_details" {
    description = "Key networking details for the web server"
    value = jsonencode({
        instance_id = aws_instance.ec2_instance.id
        public_ip   = aws_instance.ec2_instance.public_ip
        private_ip  = aws_instance.ec2_instance.private_ip
    })
}

output "db_instance_details" {
    description = "Key networking details for the Database server"
    value = jsonencode({
        instance_id         = aws_db_instance.rds_instance.id
        instance_endpoint   = aws_db_instance.rds_instance.endpoint
        instance_port       = aws_db_instance.rds_instance.port
        username            = aws_db_instance.rds_instance.username
        password            = var.db_password
        # password            = nonsensitive(var.db_password)
    })
    sensitive = true
}

output "security_group_details" {
    description = "Key networking details for the Security Group"
    value = jsonencode({
        security_group_id = aws_security_group.demo_sg.id
        security_group_name = aws_security_group.demo_sg.name
    })
}

output "user_login_details" {
    description = "AWS login details for the user"
    value       = jsonencode(module.iam_user.user_login_details)
    sensitive   = true
}

# output "load_balancer_details" {
#     description = "Key networking details for the Load Balancer"
#     value = {
#         load_balancer_arn = aws_lb.demo_lb.arn
#         load_balancer_dns = aws_lb.demo_lb.dns_name
#     }
# }

