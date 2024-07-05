# --- modules/redis/outputs.tf ---

output "endpoint_address" {
  value = aws_elasticache_cluster.wating_room_auth_tokens_terraform.cache_nodes[0].address
}