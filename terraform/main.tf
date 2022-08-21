terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "suburbproject-tf-backend"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
  }
  }

resource "aws_s3_bucket" "SBX-B" {
  bucket = "sbx-suburbproject-api-responses"
  tags = {
    Environment = "PPD"
  }
}

resource "aws_s3_bucket" "PPD-B" {
  bucket = "ppd-suburbproject-api-responses"
  tags = {
    Environment = "PPD"
  }
}

resource "aws_s3_bucket" "PROD-B" {
  bucket = "prod-suburbproject-api-responses"
  tags = {
    Environment = "PROD"
  }
}