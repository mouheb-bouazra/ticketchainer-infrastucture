# --- modules/redis/main.tf ---

resource "aws_elasticache_subnet_group" "wating_room_subnet_group" {
  name       = "wating-room-subnet-group"
  subnet_ids = var.vpc_subnet_ids
}

resource "aws_elasticache_cluster" "wating_room_auth_tokens_terraform" {
  cluster_id           = "wating-room-auth-tokens-terraform"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"

  engine_version     = "7.0"
  port               = 6379
  security_group_ids = var.vpc_security_group_ids
  subnet_group_name  = aws_elasticache_subnet_group.wating_room_subnet_group.name

  tags = {
    Name = "wating-room-auth-tokens-terraform"
  }
}
