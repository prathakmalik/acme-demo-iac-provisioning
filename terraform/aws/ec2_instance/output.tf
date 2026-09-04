# Output Variables

output "ec2_instance_details" {
  description = "Key networking details for the web server"
  value = {
    aws_user_arn  = local.requester_user_arn
    aws_user_name = local.requester_user_name
    login_user    = local.ec2_default_user
    instance_id   = aws_instance.ec2_instance.id
    instance_name = aws_instance.ec2_instance.tags["Name"]
    public_ip     = aws_instance.ec2_instance.public_ip
    private_ip    = aws_instance.ec2_instance.private_ip
  }
}
