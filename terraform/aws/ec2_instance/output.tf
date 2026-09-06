# Output Variables

output "compute_instance_details" {
  description = "Key networking details for the web server"
  value = {
    login_user    = local.ec2_default_user
    instance_id   = aws_instance.ec2_instance.id
    instance_name = aws_instance.ec2_instance.tags["Name"]
    instance_arn  = aws_instance.ec2_instance.arn
    public_ip     = aws_instance.ec2_instance.public_ip
    private_ip    = aws_instance.ec2_instance.private_ip
  }
}

output "user_login_details" {
  description = "AWS login details for the user"
  value       = jsonencode(module.iam_user.user_login_details)
  sensitive   = true
}
