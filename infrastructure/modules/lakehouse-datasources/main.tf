#Create AWS S3 Buckets for ingesting files
#Create AWS IAM Policy and attach to IAM Role
#Create Snowflake Schemas
#Create Snowflake Stages
#Create Snowflake Pipes


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
  #role = aws_iam_role.injest_bucket_role.id #Attaches policy to the global IAM role create in Core
  #role = module.lakehouse-core.outputs.iam_role_injest_bucket_id.value #Attaches policy to the role create below
  #role = "1234"
  role = var.injest_bucket_iam_role
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

#Create Snowflake Schema in RAW database
resource "snowflake_schema" "raw_schema" {
  database            = var.sf_database_name
  name                = "${var.datasource}"
  data_retention_days = 14
}

#Create Snowflake Stage for Parquet files
resource "snowflake_stage" "stage_parquet" {
  name                = "STAGE_PARQUET"
  url                 = "s3://sbx-suburbproject-api-responses-parquet"
  database            = var.sf_database_name
  schema              = snowflake_schema.raw_schema.name
  file_format         = "TYPE=PARQUET"
  storage_integration = var.integrationid
}

#Create Snowflake Stage for JSON files
resource "snowflake_stage" "stage_json" {
  name                = "STAGE_JSON"
  url                 = "s3://sbx-suburbproject-api-responses-json"
  database            = var.sf_database_name
  schema              = snowflake_schema.raw_schema.name
  file_format         = "TYPE=JSON"
  storage_integration = var.integrationid
}



