data "aws_iam_users" "search_user" {
  name_regex = "^${var.requester_username}$"
}

resource "aws_iam_user" "create_user" {
  # Only create a new user, if search_user returned no results (i.e. the user does not already exist)
  count = length(data.aws_iam_users.search_user.names) == 0 ? 1 : 0

  name = var.requester_username
  path = "/FIT-Users/"

  tags = {
    Name              = var.requester_username
    Environment       = "Demo"
    Decommission-Date = var.decommission_date
  }
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
