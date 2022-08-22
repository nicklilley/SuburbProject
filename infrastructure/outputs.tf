#To do: Call these variables via Python
output "sbx-api-response-s3" {
  description = "Name of SBX bucket"
  value       = aws_s3_bucket.SBX-B.bucket
}

output "ppd-api-response-s3" {
  description = "Name of PPD bucket"
  value       = aws_s3_bucket.PPD-B.bucket
}

output "prod-api-response-s3" {
  description = "Name of PROD bucket"
  value       = aws_s3_bucket.PROD-B.bucket
}
