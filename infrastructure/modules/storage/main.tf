#Create database
#Create schema

#Create AWS S3 Bucket
#Create AWS IAM Role
#Create AWS IAM Policy and attach to IAM Role
#Create Snowflake Create Storage Integration

resource "snowflake_database" "db-raw" {
  name                        = upper("${var.env}_RAW")
  comment                     = "test comment"
  data_retention_time_in_days = 3
}

#resource "snowflake_schema" "schema" {
#  database = snowflake_database.db-raw.name
#  name     = "schema"
#  comment  = "A schema."

#  is_transient        = false
#  is_managed          = false
#  data_retention_days = 3
#}

#Create S3 Bucket for injesting json files
resource "aws_s3_bucket" "injest-bucket-json" {
  bucket = lower("${var.env}-${var.datasource}-injest-json")
  tags = {
    environment = "${var.env}"
  }
}

#Create S3 Bucket for injesting parquet files
resource "aws_s3_bucket" "injest-bucket-parquet" {
  bucket = lower("${var.env}-${var.datasource}-injest-parquet")
  tags = {
    environment = "${var.env}"
  }
}

#Creates IAM Policy for above S3 buckets
resource "aws_iam_role_policy" "injest_bucket_policy" {
  name = "injest_bucket_policy"
  role = aws_iam_role.injest_bucket_role.id #Attaches policy to the role create below
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
        #Resource = "arn:aws:s3:::${aws_s3_bucket.injest-bucket.bucket}*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.injest-bucket-json.bucket}*",
          "arn:aws:s3:::${aws_s3_bucket.injest-bucket-parquet.bucket}*"
        ]
      },
    ]
  })
}

#Get Snowflake account details for use in IAM Role
data "snowflake_current_account" "this" {}

#Creates IAM Role for all buckets and allows Snowflake account to access buckets
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
      {
        Sid    = ""
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = { "AWS": "*" }
        Condition = {
          "StringLike": {
            "sts:ExternalId": "${data.snowflake_current_account.this.account}_SFCRole=*"
          }
        }
      },     
    ]
  })
}

data "aws_iam_role" "example" {
  name = "injest_bucket_role"
}

#Create storage integration for this environment for all buckets
resource "snowflake_storage_integration" "integration" {
  name    = upper("${var.env}_STORAGE_INTEGRATION")
  comment = "${var.env} storage integration for S3."
  type    = "EXTERNAL_STAGE"
  enabled = true
  storage_provider         = "S3"
  storage_aws_role_arn     = aws_iam_role.injest_bucket_role.arn
  storage_allowed_locations = ["*"] #Allow all S3 bucket locations
  #storage_allowed_locations = ["s3://${var.env}*"] #Wildcard doesn't work
  #storage_allowed_locations = ["s3://sbx-suburbproject-api-responses/"] Specific bucket works
}

resource "snowflake_stage" "test_stage" {
  name                = "STAGE_PARQUET"
  url                 = "s3://sbx-suburbproject-api-responses-parquet"
  database            = upper("${var.env}_RAW")
  schema              = "${var.datasource}"
  file_format         = "TYPE=PARQUET"
  storage_integration = snowflake_storage_integration.integration.name
}

resource "snowflake_stage" "test_stageb" {
  name                = "${var.datasource}_STAGE_JSON"
  url                 = "s3://sbx-suburbproject-api-responses-json"
  database            = upper("${var.env}_RAW")
  schema              = "${var.datasource}"
  file_format         = "TYPE=JSON"
  storage_integration = snowflake_storage_integration.integration.name
}
  #file_format = "TYPE=CSV COMPRESSION=GZIP FIELD_OPTIONALLY_ENCLOSED_BY= '\"' SKIP_HEADER=1"

# TO DOOOOOOO
#create file format my_parquet_format
#  type = parquet;


/*
resource "snowflake_stage_grant" "snowflake_s3_backup" {
  provider      = snowflake.security_admin
  database_name = snowflake_stage.snowflake_s3_backup.database
  schema_name   = snowflake_stage.snowflake_s3_backup.schema
  roles         = [
    snowflake_role.sandbox_rw.name,
  ]
  privilege     = "USAGE"
  stage_name    = snowflake_stage.snowflake_s3_backup.name
}
*/


