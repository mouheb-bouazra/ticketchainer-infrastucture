# --- modules/authorizer/variables.tf ---

variable "api_gateway_id" {
  description = "ID of the API Gateway"
  type        = string
}

variable "authorizer_name" {
  description = "Name of the authorizer"
  type        = string
  default     = "customAuthValidatorApi-terraform"
}

variable "lambda_authorizer_arn" {
  description = "ARN of the Lambda function to be used as the authorizer"
  type        = string
  default = null
}

variable "lambda_authorizer_uri" {
  description = "URI of the authorizer"
  type        = string
}
