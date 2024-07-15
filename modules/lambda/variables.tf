# --- modules/lambda/variables.tf ---


variable "vpc_id" {}
variable "vpc_subnet_ids" {
  description = "List of VPC Subnet IDs"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC Security Group IDs"
  type        = list(string)
}

variable "jwt_public_key" {
  type = string
}

variable "redis_endpoint" {
  type = string
}

variable "api_gateway_execution_arn" {
  type = string
}


variable "region" {
  type = string
}
variable "enabled_for_orgs" {
  type = string
}