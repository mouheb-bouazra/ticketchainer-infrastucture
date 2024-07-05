# --- root/outputs.tf ---

output "vpc" {
  value = {
    id                = module.vpc.vpc_id
    # subnet_ids         = module.vpc.subnet_ids # maybe i need to export this
    redis_sg_id = module.security_group.redis_sg_id
    lambda_sg_id = module.security_group.lambda_sg_id
  }
}

output "api_gateway_id" {
  value = module.api_gateway.instance.id
}

output "api_gateway_execution_arn" {
  value = module.api_gateway.instance.execution_arn
}

output "lambda_arn" {
  value = module.lambda.lambda_instance.arn
}

output "redis_endpoint" {
  value = module.redis.endpoint_address
}
