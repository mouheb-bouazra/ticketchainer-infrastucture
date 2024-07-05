# --- modules/api_gateway/main.tf ---

# aws protected lambda function
data "aws_lambda_function" "protected_lambda" {
  function_name = "protectedAPI"
}

data "aws_api_gateway_rest_api" "custom_auth_api" {
  name = var.api_gateway_name
}

data "aws_api_gateway_resource" "custom_auth_api" {
  rest_api_id = data.aws_api_gateway_rest_api.custom_auth_api.id
  path        = "/"
}

resource "aws_api_gateway_request_validator" "method_request_validator" {
  name                        = "Validate request headers"
  rest_api_id                 = data.aws_api_gateway_rest_api.custom_auth_api.id
  validate_request_body       = false
  validate_request_parameters = false
}

resource "aws_api_gateway_method" "custom_auth_method" {
  rest_api_id          = data.aws_api_gateway_rest_api.custom_auth_api.id
  resource_id          = data.aws_api_gateway_resource.custom_auth_api.id
  http_method          = "GET"
  authorization        = "CUSTOM"
  authorizer_id        = var.authorizer_id
  request_validator_id = aws_api_gateway_request_validator.method_request_validator.id
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = data.aws_api_gateway_rest_api.custom_auth_api.id
  resource_id             = data.aws_api_gateway_resource.custom_auth_api.id
  http_method             = aws_api_gateway_method.custom_auth_method.http_method
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = data.aws_lambda_function.protected_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = data.aws_api_gateway_rest_api.custom_auth_api.id
  resource_id = data.aws_api_gateway_resource.custom_auth_api.id
  http_method = aws_api_gateway_method.custom_auth_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "integration-response" {
  rest_api_id = data.aws_api_gateway_rest_api.custom_auth_api.id
  resource_id = data.aws_api_gateway_resource.custom_auth_api.id
  http_method = aws_api_gateway_method.custom_auth_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  depends_on = [aws_api_gateway_method.custom_auth_method]
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.protected_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${data.aws_api_gateway_rest_api.custom_auth_api.execution_arn}/*/${aws_api_gateway_method.custom_auth_method.http_method}${data.aws_api_gateway_resource.custom_auth_api.path}"
}

resource "aws_api_gateway_deployment" "custom_auth_deployment" {
  rest_api_id = data.aws_api_gateway_rest_api.custom_auth_api.id
  stage_name  = "mouheb"

  depends_on = [aws_api_gateway_method.custom_auth_method, aws_api_gateway_integration.integration]
}
