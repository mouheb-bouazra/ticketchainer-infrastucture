# --- modules/authorizer/main.tf ---

resource "aws_api_gateway_authorizer" "customAuthValidatorApi-terraform" {
  name                   = var.authorizer_name
  rest_api_id            = var.api_gateway_id
  authorizer_uri         = var.lambda_authorizer_uri
  # authorizer_credentials = var.lambda_authorizer_arn
  type = "REQUEST"
  identity_source = "method.request.header.authorization"
  authorizer_result_ttl_in_seconds = 5
}
