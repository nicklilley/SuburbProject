variable "env" {
  type = string
  description = "Environment for deployment"
}

variable "datasource" {
  type = string
  description = "Name of the datasource or source system"
}

variable "integrationid" {
  type = string
}

variable "injest_bucket_iam_role" {
  type = string
}

variable "sf_database_name" {
  type = string
}

