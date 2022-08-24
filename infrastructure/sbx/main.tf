#Create Terraform Backend on S3
#Run all Lakehouse-Core Modules
#Run all Lakehouse-Datasources Modules


#Set Terraform backend to S3 to hold State and other files
#Note: Backend bucket must be created before running this script
terraform {
  backend "s3" {
    bucket = "sbx-suburbproject-tf-backend"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
  }
  }

#Creates infrastructure based on contents of lakehouse-core directory
module "lakehouse-core" {
  source   = "../modules/lakehouse-core"
  env      = var.env
}

#Creates a new suite of infrastructure for a new datasource.
#Creates infrastructure based on contents of lakehouse-datasoruce directory
module "lakehouse-datasource-domain" {
  source                     = "../modules/lakehouse-datasources"
  datasource                 = upper("domain-api") ### ENTER DATASOURCE NAME ###
  env                        = var.env
  sf_database_name           = module.lakehouse-core.sf_database_name
  integrationid              = module.lakehouse-core.integrationid
  injest_bucket_iam_role     = module.lakehouse-core.injest_bucket_iam_role
  #injest_bucket_iam_role_arn = module.lakehouse-core.injest_bucket_iam_role_arn
}

/*

#Creates a new suite of infrastructure for a new datasource.
#Creates infrastructure based on contents of lakehouse-datasoruce directory
module "lakehouse-datasource-schools"   {
  source                 = "../modules/lakehouse-datasources"
  datasource             = upper("schools-api") ### ENTER DATASOURCE NAME ###
  sf_database_name       = module.lakehouse-core.sf_database_name
  env                    = var.env
  integrationid          = module.lakehouse-core.integrationid
  injest_bucket_iam_role  = module.lakehouse-core.injest_bucket_iam_role
  #injest_bucket_iam_role_arn = module.lakehouse-core.injest_bucket_iam_role_arn
}

*/