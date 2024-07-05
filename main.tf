# --- root/main.tf ---

module "vpc" {
  source             = "./modules/vpc"
  cidr_block         = var.cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

module "redis" {
  source                 = "./modules/redis"
  vpc_id                 = module.vpc.vpc_id
  vpc_subnet_ids         = module.vpc.subnet_ids
  vpc_security_group_ids = [module.security_group.redis_sg_id]
}

module "lambda" {
  source                    = "./modules/lambda"
  vpc_id                    = module.vpc.vpc_id
  vpc_subnet_ids            = module.vpc.subnet_ids
  vpc_security_group_ids    = [module.security_group.lambda_sg_id]
  jwt_public_key            = var.jwt_public_key
  redis_endpoint            = module.redis.endpoint_address
  api_gateway_execution_arn = module.api_gateway.instance.execution_arn
}

module "api_gateway" {
  source           = "./modules/api_gateway"
  api_gateway_name = "CustomAuthApi"
  authorizer_id    = module.authorizer.instance_id
}

module "authorizer" {
  source                = "./modules/authorizer"
  authorizer_name       = "customAuthValidatorApi-terraform"
  api_gateway_id        = module.api_gateway.instance.id
  lambda_authorizer_uri = module.lambda.lambda_instance.invoke_arn
  # lambda_authorizer_arn           = module.lambda.lambda_instance.arn
}
