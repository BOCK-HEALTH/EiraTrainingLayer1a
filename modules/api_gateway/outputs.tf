

output "api_invoke_url" {
	value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.region}.amazonaws.com/${var.api_stage_name}/${var.api_resource_path}"
	description = "Invoke URL for the deployed API Gateway."
}
