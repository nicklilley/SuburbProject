#Create Snowflake Databases
#Create Snowflake Storage Integration for S3
#Create AWS IAM Role to allow Snowflake to interact with S3

#Create Raw database for landing data
resource "snowflake_database" "db-raw" {
  name                        = upper("${var.env}_RAW")
  comment                     = "Raw database for landing data"
  data_retention_time_in_days = 3
}

#Create PREP database for DBT source models and transformations
resource "snowflake_database" "db-prep" {
  name                        = upper("${var.env}_PREP")
  comment                     = "Prep data for DBT source models and transformations"
  data_retention_time_in_days = 3
}

#Create Analytics database data consumption
resource "snowflake_database" "db-analytics" {
  name                        = upper("${var.env}_ANALYTICS")
  comment                     = "Analytics or PROD database for consuming data"
  data_retention_time_in_days = 3
}

#Create Warehouse for transforming data 
resource snowflake_warehouse w {
  name           = "TRANSFORMING"
  warehouse_size = "x-small"
}

#Create Snowflake Schema in PREP database
resource "snowflake_schema" "prep_schema" {
  database            = snowflake_database.db-prep.name
  name                = "PREPERATION"
  data_retention_days = 14
  depends_on          = [snowflake_database.db-prep]
}

#Create Snowflake Schema in Analytics database
resource "snowflake_schema" "common_schema" {
  database            = upper("${var.env}_ANALYTICS")
  name                = "COMMON"
  data_retention_days = 14
  depends_on          = [snowflake_database.db-analytics]
}

#Get Snowflake account details for use in IAM Role
#data "snowflake_current_account" "this" {}

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
            #"sts:ExternalId": "${data.snowflake_current_account.this.account}_SFCRole=*"
             "sts:ExternalId": "${local.snowflake_creds.account}_SFCRole=*"
          }
        }
      },     
    ]
  })
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
