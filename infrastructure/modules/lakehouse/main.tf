resource "snowflake_schema" "schema" {
  database            = "RAW"
  name                = "TFTEST2"
  data_retention_days = 1
}

