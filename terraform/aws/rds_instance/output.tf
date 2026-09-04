# Output Variables

output "db_instance_details" {
    description = "Key networking details for the Database server"
    value = {
        instance_id = aws_db_instance.rds_instance.id
        instance_endpoint = aws_db_instance.rds_instance.endpoint
        instance_port = aws_db_instance.rds_instance.port
        username = aws_db_instance.rds_instance.username
        password = var.db_password
        # password = nonsensitive(var.db_password)
    }
    sensitive = true
}

output "user_login_details" {
    description = "AWS login details for the user"
    value = {
        username = local.requester_user_name
        password = module.iam_user.user_password
    }
    sensitive = true
}

