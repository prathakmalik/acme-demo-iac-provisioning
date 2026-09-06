# Output Variables

output "storage_bucket_details" {
  description = "Structural configuration and access metrics for the new S3 bucket"
  value = jsonencode(module.s3_bucket.storage_bucket_details)
}

output "compute_instance_details" {
  description = "Key networking details for the web server"
  value = jsonencode(module.compute_instance.compute_instance_details)
}

output "db_instance_details" {
  description = "Key networking details for the Database server"
  value = jsonencode(module.db_instance.db_instance_details)
  sensitive = true
}

output "security_group_details" {
  description = "Key networking details for the Security Group"
  value = jsonencode({
    security_group_id   = aws_security_group.demo_sg.id
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

