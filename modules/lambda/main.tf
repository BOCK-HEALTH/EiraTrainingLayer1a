resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  role          = var.lambda_role_arn

  filename         = "${path.module}/lambda_function_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function_payload.zip")

  environment {
    variables = {
      YOUTUBE_API_KEY = var.youtube_api_key
    }
  }
}