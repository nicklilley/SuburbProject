output "injest_bucket_iam_role" {
  value = aws_iam_role.injest_bucket_role.id
}

#output "injest_bucket_iam_role_arn" {
#  value = aws_iam_role.injest_bucket_role.arn
#}


output "integrationid" {
  value = snowflake_storage_integration.integration.name
}

output "sf_database_name" {
  value = snowflake_database.db-raw.name
}
