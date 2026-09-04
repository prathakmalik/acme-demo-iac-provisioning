# Allow user to access the newly created S3 bucket for read/write operations

data "aws_iam_users" "search_user" {
  # user_name = var.requester_username
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
  requester_user_arn = length(data.aws_iam_users.search_user.names) > 0 ? tolist(data.aws_iam_users.search_user.arns)[0] : aws_iam_user.create_user[0].arn
  requester_user_name = length(data.aws_iam_users.search_user.names) > 0 ? tolist(data.aws_iam_users.search_user.names)[0] : aws_iam_user.create_user[0].name
}

# Grant the user access to the S3 bucket console
resource "aws_iam_user_policy" "s3_console_access" {
  user = local.requester_user_name
  name = "S3GlobalConsoleVisibility"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowUserToListAllBucketsInConsole"
        Effect   = "Allow"
        Action   = ["s3:ListAllMyBuckets"]
        Resource = ["*"] 
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

