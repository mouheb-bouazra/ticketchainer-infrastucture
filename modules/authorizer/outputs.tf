# --- modules/authorizer/outputs.tf ---


output "instance_id" {
  value = aws_api_gateway_authorizer.customAuthValidatorApi-terraform.id
}
