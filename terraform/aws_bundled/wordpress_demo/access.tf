# Allow user to access the newly created S3 bucket for read/write operations

module "iam_user" {
  source = "../../aws/modules/iam-user"

  requester_username = var.requester_username
  decommission_date  = var.decommission_date
}

locals {
  requester_user_arn  = module.iam_user.user_login_details.userarn
  requester_user_name = module.iam_user.user_login_details.username
  rds_default_user    = "admin"
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
        Resource = [module.compute_instance.compute_instance_details.instance_arn]
        Condition = {
          StringEquals = {
            "ec2:osuser" = local.ec2_default_user
          }
        }
      },
      # Grant permission to view the EC2 console and see their specific instance
      {
        Sid      = "AllowUserToSeeEC2Dashboard"
        Effect   = "Allow"
        Action   = ["ec2:Describe*"]
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
        Resource = [module.compute_instance.compute_instance_details.instance_arn]
      }
    ]
  })
}

# Grant the user access to the S3 and RDS console
resource "aws_iam_policy" "combined_console_access_policy" {
  name        = "S3_RDS_GlobalConsoleVisibility"
  description = "Combined managed policy for S3, RDS, and CloudShell console access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Grant full authorization to launch and approve the CloudShell console environment
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
        Resource = ["*"]
      },
      # Grant permission to list all buckets in the S3 console
      {
        Sid      = "AllowUserToListAllBucketsInConsole"
        Effect   = "Allow"
        Action   = ["s3:ListAllMyBuckets"]
        Resource = ["*"]
      },
      # Grant permission to view the RDS console dashboard
      {
        Sid      = "AllowUserToSeeRDSDashboard"
        Effect   = "Allow"
        Action   = ["rds:Describe*"]
        Resource = ["*"]
      },
      # Grant permission for hidden telemetry actions required to render console graphs
      {
        Sid    = "AllowConsoleUIMetadataDiscovery"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "ec2:Describe*",
          "rds:Describe*"
        ]
        Resource = ["*"]
      },
      # Restrict execution explicitly to their specific RDS ARN for absolute safety
      {
        Sid    = "AllowControlOfSpecificDatabaseOnly"
        Effect = "Allow"
        Action = [
          "rds:StartDBInstance",
          "rds:StopDBInstance",
          "rds:RebootDBInstance"
        ]
        Resource = [module.db_instance.db_instance_details.instance_arn]
      }
    ]
  })
}

# Attach the Managed Policy to the User
resource "aws_iam_user_policy_attachment" "combined_access_attach" {
  user       = local.requester_user_name
  policy_arn = aws_iam_policy.combined_console_access_policy.arn
}

# Grant the user access to the newly created S3 bucket for read/write/delete operations
resource "aws_s3_bucket_policy" "allow_access" {
  bucket = module.s3_bucket.storage_bucket_details.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBucketListing"
        Effect = "Allow"
        Principal = {
          AWS = local.requester_user_arn
        }
        Action   = ["s3:ListBucket"]
        Resource = "${module.s3_bucket.storage_bucket_details.bucket_arn}"
      },
      {
        Sid    = "AllowDirectAccess"
        Effect = "Allow"
        Principal = {
          AWS = local.requester_user_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${module.s3_bucket.storage_bucket_details.bucket_arn}/*"
      }
    ]
  })
}

