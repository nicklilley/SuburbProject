terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.35"
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

#Set Snowflake account details
provider "snowflake" {
  account = "iv46657"
  username = local.snowflake_creds.username
  password = local.snowflake_creds.password
  region = "ap-southeast-2"
  role = "ACCOUNTADMIN"
}

