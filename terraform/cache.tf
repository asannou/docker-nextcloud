resource "aws_elasticache_subnet_group" "elasticache" {
  name       = "nextcloud-${random_id.nextcloud.dec}"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}

resource "aws_security_group" "elasticache" {
  name_prefix = "nextcloud-elasticache-redis-"
  vpc_id      = var.vpc_id
  tags = {
    Name = "nextcloud-elasticache-redis"
  }
}

resource "aws_security_group_rule" "elasticache-ingress" {
  security_group_id        = aws_security_group.elasticache.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6379
  to_port                  = 6379
  source_security_group_id = aws_security_group.web-all.id
}

resource "aws_elasticache_replication_group" "elasticache" {
  replication_group_id       = "nextcloud-${random_id.nextcloud.dec}"
  description                = "nextcloud"
  num_cache_clusters         = 1
  node_type                  = var.elasticache_node_type
  automatic_failover_enabled = false
  auto_minor_version_upgrade = true
  engine                     = "redis"
  engine_version             = var.elasticache_engine_version
  parameter_group_name       = var.elasticache_parameter_group_name
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.elasticache.name
  security_group_ids         = [aws_security_group.elasticache.id]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = aws_kms_key.nextcloud.arn
  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
}

