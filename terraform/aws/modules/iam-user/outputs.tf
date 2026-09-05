locals {
  user_created = length(data.aws_iam_users.search_user.names) == 0
}

output "user_login_details" {
    description = "AWS login details for the user"
    value = jsonencode({
        user_created = local.user_created
        username = local.user_created ? aws_iam_user.create_user[0].name : tolist(data.aws_iam_users.search_user.names)[0]
        userarn = local.user_created ? aws_iam_user.create_user[0].arn : tolist(data.aws_iam_users.search_user.arns)[0]
        password = local.user_created ? aws_iam_user_login_profile.developer_login[0].password : null
    })
    sensitive = true
}
