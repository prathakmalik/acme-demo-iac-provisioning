# Allow user to access the newly created RDS Database instance

# --------------------DB Access test is not possible with Cloudshell------------------------
# Unable to create the environment. Your account verification is in progress.
# This may take up to two days for new accounts. To retry, delete the environment by selecting
# Actions, Delete and then try again. If you have any further questions, contact AWS Support .

module "iam_user" {
  source = "../modules/iam-user"

  requester_username = var.requester_username
  decommission_date  = var.decommission_date
}

locals {
  requester_user_arn  = module.iam_user.user_arn
  requester_user_name = module.iam_user.user_name
  rds_default_user    = "admin"
}

# Grant the user access to the RDS console
resource "aws_iam_user_policy" "rds_instance_access" {
  user = local.requester_user_name
  name = "RDSInstanceVisibilityAndAccess"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Grant full authorization to launch and approve the console container environment
      {
        Sid    = "AllowUserToLaunchCloudShell"
        Effect = "Allow"
        Action = [
          "cloudshell:CreateEnvironment",
          "cloudshell:DeleteEnvironment",
          "cloudshell:GetEnvironmentStatus",
          "cloudshell:StartEnvironment",
          "cloudshell:ApproveCommand",
          "cloudshell:PutCredentials"
        ]
        # CloudShell environments are global management tools and must target "*"
        Resource = ["*"] 
      },
      # Grant permission to view the RDS console and see their specific instance
      {
        Sid    = "AllowUserToSeeRDSDashboard"
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBSubnetGroups",
          "rds:DescribeDBParameterGroups",
          "rds:DescribeDBSecurityGroups",
          "rds:DescribeEngineDefaultParameters",
          "rds:DescribeDBClusterParameterGroups",
          "rds:DescribeDBClusters",
          "rds:DescribeGlobalClusters"
        ]
        Resource = ["*"]
      },
      # Grant permission for hidden telemetry actions the console forces to compile page layout
      {
        Sid    = "AllowConsoleUIMetadataDiscovery"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Resource = ["*"] # Required by AWS to render the RDS monitoring graphs
      },
      # Grant permission to start/stop/reboot their specific instance
      {
        Sid    = "AllowControlOfSpecificDatabaseOnly"
        Effect = "Allow"
        Action = [
          "rds:StartDBInstance",
          "rds:StopDBInstance",
          "rds:RebootDBInstance"
        ]
        # Restrict execution explicitly to their specific RDS ARN for absolute safety
        Resource = ["${aws_db_instance.rds_instance.arn}"]
      }
    ]
  })
}

