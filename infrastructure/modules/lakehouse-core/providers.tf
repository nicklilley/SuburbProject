terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.41"
    }
  }
}

#Fetch credentials from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "snowflake-creds"
}

#Put credentials in a Local variable
locals {
  snowflake_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}