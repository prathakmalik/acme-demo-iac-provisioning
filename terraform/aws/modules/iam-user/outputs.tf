output "user_arn" {
  description = "The ARN of the resolved IAM user (either existing or newly created)"
  value       = length(data.aws_iam_users.search_user.names) > 0 ? tolist(data.aws_iam_users.search_user.arns)[0] : aws_iam_user.create_user[0].arn
}

output "user_name" {
  description = "The name of the resolved IAM user (either existing or newly created)"
  value       = length(data.aws_iam_users.search_user.names) > 0 ? tolist(data.aws_iam_users.search_user.names)[0] : aws_iam_user.create_user[0].name
}

output "user_password" {
  description = "The initial password for the created IAM user"
  value       = length(data.aws_iam_users.search_user.names) == 0 ? aws_iam_user_login_profile.developer_login[0].password : null
  sensitive   = true
}
