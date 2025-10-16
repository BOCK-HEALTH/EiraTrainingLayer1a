module "s3" {
  source         = "../../modules/s3"
  bucket_name    = var.bucket_name
  api_gateway_url = module.api_gateway.api_invoke_url
}

module "iam" {
  source = "../../modules/iam"
}

module "lambda" {
  source                = "../../modules/lambda"
  lambda_function_name  = var.lambda_function_name
  lambda_handler        = var.lambda_handler
  lambda_runtime        = var.lambda_runtime
  lambda_timeout        = var.lambda_timeout
  lambda_role_arn       = module.iam.lambda_role_arn
  youtube_api_key       = var.youtube_api_key
}

module "api_gateway" {
  source               = "../../modules/api_gateway"
  api_gateway_name     = var.api_gateway_name
  api_resource_path    = var.api_resource_path
  lambda_invoke_arn    = module.lambda.lambda_function_arn
  lambda_function_name = module.lambda.lambda_function_name
  api_stage_name       = var.api_stage_name
}