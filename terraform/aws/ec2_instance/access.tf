# Allow user to access the newly created EC2 instance

data "aws_iam_users" "search_user" {
  name_regex = "^${var.requester_username}$"
}

resource "aws_iam_user" "create_user" {
  count = length(data.aws_iam_users.search_user.names) == 0 ? 1 : 0

  name = var.requester_username
  path = "/FIT-Users/"

  tags = {
    Name              = var.requester_username
    Environment       = "Demo"
    Decommission-Date = var.decommission_date
  }
}

locals {
  requester_user_arn  = length(data.aws_iam_users.search_user.names) > 0 ? tolist(data.aws_iam_users.search_user.arns)[0] : aws_iam_user.create_user[0].arn
  requester_user_name = length(data.aws_iam_users.search_user.names) > 0 ? tolist(data.aws_iam_users.search_user.names)[0] : aws_iam_user.create_user[0].name
  ec2_default_user    = "ec2-user" # Standard Amazon Linux AMIs use "ec2-user" as the baseline terminal login name
}

# Grant the user access to the EC2 console
resource "aws_iam_user_policy" "ec2_instance_access" {
  user = local.requester_user_name
  name = "EC2InstanceVisibilityAndAccess"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Grant permission to push the temporary key into the instance IMDS
      {
        Sid      = "AllowInstanceConnectPushKey"
        Effect   = "Allow"
        Action   = ["ec2-instance-connect:SendSSHPublicKey"]
        Resource = ["${aws_instance.ec2_instance.arn}"]
        Condition = {
          StringEquals = {
            "ec2:osuser" = local.ec2_default_user
          }
        }
      },
      # Grant permission to view the EC2 console and see their specific instance
      {
        Sid    = "AllowUserToSeeEC2Dashboard"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeRouteTables",
          "ec2:DescribeImages",
          "ec2:DescribeAddresses",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeRegions",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeSecurityGroupRules"
        ]
        Resource = ["*"]
      },
      # Grant permission to start/stop/reboot their specific instance
      {
        Sid    = "AllowControlOfSpecificInstanceOnly"
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances"
        ]
        # Restrict execution explicitly to their specific EC2 ARN for absolute safety
        Resource = ["${aws_instance.ec2_instance.arn}"]
      }
    ]
  })
}

