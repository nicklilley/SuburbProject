terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
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
