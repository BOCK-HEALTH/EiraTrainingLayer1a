output "bucket_name" {
  value = aws_s3_bucket.static_site.bucket
  description = "The name of the S3 bucket."
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.static_site.website_endpoint
  description = "The website endpoint URL."
}
