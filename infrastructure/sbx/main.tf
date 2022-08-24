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

#Create Raw database for staging data
resource "snowflake_database" "db-test" {
  name                        = "test123451"
  comment                     = "test comment"
  data_retention_time_in_days = 3
}


#Creates infrastructure based on contents of lakehouse-core directory
module "lakehouse-core" {
  source   = "../modules/lakehouse-core"
  env      = var.env
}

resource "time_sleep" "wait_10_seconds" {
  depends_on = [
    module.lakehouse-core
  ]
 
  create_duration = "10s"
}

#Creates a new suite of infrastructure for parquet datasource(s) by looping through for_each value
#Creates infrastructure based on contents of lakehouse-datasoruce directory
#Note: Template file PER DATASOURCE must be present in \sbx\file-template
module "lakehouse-datasource-parquet" {
  source                     = "../modules/lakehouse-datasources" 
  for_each                   = toset(["domain-api","abcdefgh"]) ### ENTER DATASOURCE NAME INTO ARRAY ###
  datasource                 = upper(each.key) #Converts to uppercase and loops through each item in for_each array and creates resources
  file_type                  = "parquet"
  env                        = var.env
  #datasource                 = upper("domain-api") ### ENTER DATASOURCE NAME ###
  sf_database_name           = module.lakehouse-core.sf_database_name
  integrationid              = module.lakehouse-core.integrationid
  injest_bucket_iam_role     = module.lakehouse-core.injest_bucket_iam_role
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