# --- modules/api_gateway/outputs.tf ---

output "instance" {
  value = data.aws_api_gateway_rest_api.custom_auth_api
}

output "lmabda_integraton_method" {
  value = aws_api_gateway_method.custom_auth_method.http_method
}