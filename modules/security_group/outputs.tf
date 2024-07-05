# --- modules/security_group/outputs.tf ---


output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "redis_sg_id" {
  value = aws_security_group.redis_sg.id
}