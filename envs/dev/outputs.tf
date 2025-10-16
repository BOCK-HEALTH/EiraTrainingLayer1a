output "s3_website_url" {
  value = module.s3.website_endpoint
  description = "The S3 static website endpoint for the frontend."
}
output "lambda_function_arn" {
  value = module.lambda.lambda_function_arn
}

output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}

output "api_gateway_url" {
  value = module.api_gateway.api_invoke_url
  description = "Invoke URL for the deployed API Gateway."
}

output "lambda_role_arn" {
  value = module.iam.lambda_role_arn
}