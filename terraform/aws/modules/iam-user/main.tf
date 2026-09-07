data "aws_iam_users" "search_user" {
  name_regex = "^${var.requester_username}$"
}

resource "aws_iam_user" "create_user" {
  # Only create a new user, if search_user returned no results (i.e. the user does not already exist)
  count = length(data.aws_iam_users.search_user.names) == 0 ? 1 : 0

  name = var.requester_username
  path = "/FIT-Users/"
  force_destroy = true

  tags = {
    Name              = var.requester_username
    Environment       = "Demo"
    Decommission-Date = var.decommission_date
  }
}

# Attach the standard, robust AWS-Managed Policy for password resets
resource "aws_iam_user_policy_attachment" "managed_password_change" {
  # Only create a password profile if a new user was actually generated
  count = length(data.aws_iam_users.search_user.names) == 0 ? 1 : 0
  depends_on = [ aws_iam_user.create_user ]

  user       = var.requester_username
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}


resource "aws_iam_user_login_profile" "developer_login" {
  # Only create a password profile if a new user was actually generated
  count = length(data.aws_iam_users.search_user.names) == 0 ? 1 : 0

  user                    = aws_iam_user.create_user[0].name
  password_length         = 16
  password_reset_required = true

  # CRITICAL: Prevent consecutive "terraform apply" commands from fighting
  # with AWS over whether the user has reset their password yet!
  lifecycle {
    ignore_changes = [
      password_reset_required,
      password_length
    ]
  }
}

locals {
  email          = var.requester_username
  parsed_username = split("@", local.email)[0]
}

resource "aws_iam_user_policy" "password_change_policy" {
  count = length(data.aws_iam_users.search_user.names) == 0 ? 1 : 0

  name = "AllowSelfPasswordChange"
  user = aws_iam_user.create_user[0].name

  # The exact JSON policy block allowing password operations on their own resource
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowUserToChangeTheirOwnPassword"
        Effect = "Allow"
        Action = [
          "iam:ChangePassword",
          "iam:GetAccountPasswordPolicy"
        ]
        Resource = "arn:aws:iam::*:user/${local.parsed_username}*" 
        # Note: Dual dollar signs ($$) escape the variable string so Terraform 
        # passes it safely to AWS IAM instead of evaluating it locally.
      }
    ]
  })
}
