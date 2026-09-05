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
}

# Grant the user access to the S3 and RDS console
resource "aws_iam_user_policy" "s3_rds_access_policy" {
  user = local.requester_user_name
  name = "S3_RDS_GlobalConsoleVisibility"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Grant permission to list all buckets in the S3 console
      {
        Sid      = "AllowUserToListAllBucketsInConsole"
        Effect   = "Allow"
        Action   = ["s3:ListAllMyBuckets"]
        Resource = ["*"]
      },
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
        Resource = ["*"]
      },
      # Grant permission to view the RDS console and see their specific instance
      {
        Sid      = "AllowUserToSeeRDSDashboard"
        Effect   = "Allow"
        Action   = ["rds:Describe*"]
        Resource = ["*"]
      },
      # Grant permission for hidden telemetry actions the console forces to compile page layout
      {
        Sid    = "AllowConsoleUIMetadataDiscovery"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "ec2:Describe*"
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

# Grant the user access to the newly created S3 bucket for read/write/delete operations
resource "aws_s3_bucket_policy" "allow_access" {
  bucket = aws_s3_bucket.s3_bucket.id

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
        Resource = "${aws_s3_bucket.s3_bucket.arn}"
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
        Resource = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}

