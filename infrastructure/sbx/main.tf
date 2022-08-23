#Create Terraform Backend on S3
#Run all Storage Modules
#Run all Infrastructure Modules


#Set Terraform backend to S3 to hold State and other files
#Note: Backend bucket must be created before running this script
terraform {
  backend "s3" {
    bucket = "sbx-suburbproject-tf-backend"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
  }
  }

#Create storage (S3 buckets) for ingesting data
module "storage" {
  source   = "../modules/storage"
  APP_NAME = var.APP_NAME
  env      = var.env
  datasource     = upper("domain-api")
}

module "lakehouse" {
  source         = "../modules/lakehouse"
  datasource     = upper("twitter-api")
  env            = var.env
}

module "lakehouse-domain" {
  source         = "../modules/lakehouse"
  datasource     = upper("domain-api")
  env            = var.env
}

module "lakehouse-schools"   {
  source         = "../modules/lakehouse"
  datasource     = upper("schools-api")
  env            = var.env
}
