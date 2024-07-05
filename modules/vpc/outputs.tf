# --- modules/lambda/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.wating-room-auth-tokens-vpc.id
}


output "subnet_ids" {
  value = data.aws_subnets.subnets.ids
}