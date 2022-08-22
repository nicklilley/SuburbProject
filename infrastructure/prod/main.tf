#Set Terraform backend to S3 to hold State and other files
#Note: Backend bucket must be created before running this script
terraform {
  backend "s3" {
    bucket = "prod-suburbproject-tf-backend"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
  }
  }

#Create storage (S3 buckets) for ingesting data
module "storage" {
  source   = "../modules/storage"
  APP_NAME = var.APP_NAME
  ENV      = var.ENV
}