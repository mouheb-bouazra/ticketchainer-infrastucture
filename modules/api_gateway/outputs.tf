# --- modules/api_gateway/outputs.tf ---

output "instance" {
  value = data.aws_api_gateway_rest_api.custom_auth_api
}