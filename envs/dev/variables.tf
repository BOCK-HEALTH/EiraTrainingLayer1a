variable "bucket_name" {
  description = "Name of the S3 bucket for static website."
  type        = string
  default     = "youtube-links-extraction"
}
variable "lambda_function_name" {
  description = "Name of the Lambda function."
  type        = string
  default     = "youtubeLinkExtractor"
}

variable "lambda_handler" {
  description = "Lambda handler."
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 60
}

variable "youtube_api_key" {
  description = "YouTube API Key for Lambda."
  type        = string
}

variable "api_gateway_name" {
  description = "API Gateway name."
  type        = string
  default     = "youtube-api"
}

variable "api_resource_path" {
  description = "API Gateway resource path."
  type        = string
  default     = "links"
}

variable "api_stage_name" {
  description = "API Gateway stage name."
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}