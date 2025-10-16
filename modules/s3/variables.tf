variable "api_gateway_url" {
  description = "The API Gateway URL to inject into the frontend"
  type        = string
}
variable "bucket_name" {
  description = "Name of the S3 bucket for static website."
  type        = string
  default     = "youtube-links-extraction"
}