#Create S3 Bucket
#Create IAM Role
#Create IAM Policy and attach to IAM Role
#To do: Create Storage Integration

#Create S3 Bucket
resource "aws_s3_bucket" "injest-bucket" {
  bucket = "${var.ENV}-${var.APP_NAME}-api-responses"
  tags = {
    Environment = "${var.ENV}"
  }
}


resource "aws_iam_role_policy" "injest_bucket_policy" {
  name = "injest_bucket_policy"
  role = aws_iam_role.injest_bucket_role.id #attachs to the role create below
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObjectVersion"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${aws_s3_bucket.injest-bucket.bucket}/*"
      },
    ]
  })
}

resource "aws_iam_role" "injest_bucket_role" {
  name = "injest_bucket_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_role" "example" {
  name = "injest_bucket_role"
}

#Create storage integration
#resource "snowflake_storage_integration" "integration" {
#  name    = "storage"
#  comment = "A storage integration."
#  type    = "EXTERNAL_STAGE"
#  enabled = true
#  storage_provider         = "S3"
#  storage_aws_role_arn     = data.aws_iam_role.injest_bucket_role.arn
#}









