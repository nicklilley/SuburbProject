resource "aws_s3_bucket" "injest-bucket" {
  bucket = "${var.ENV}-${var.APP_NAME}-api-responses"
  tags = {
    Environment = "${var.ENV}"
  }
}