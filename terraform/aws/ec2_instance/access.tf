# Allow user to access the newly created EC2 instance

module "iam_user" {
  source = "../modules/iam-user"

  requester_username = var.requester_username
  decommission_date  = var.decommission_date
}

locals {
  requester_user_arn  = module.iam_user.user_arn
  requester_user_name = module.iam_user.user_name
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
        Action = ["ec2:Describe*"]
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

