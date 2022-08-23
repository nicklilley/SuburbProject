resource "snowflake_schema" "schema" {
  database            = upper("${var.env}_RAW")
  name                = "${var.datasource}"
  data_retention_days = 14
}