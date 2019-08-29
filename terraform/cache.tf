resource "aws_elasticache_subnet_group" "elasticache" {
  name = "nextcloud"
  subnet_ids = [
    "${aws_subnet.private0.id}",
    "${aws_subnet.private1.id}",
  ]
}

resource "aws_security_group" "elasticache" {
  name = "nextcloud-elasticache-redis"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "nextcloud-elasticache-redis"
  }
}

resource "aws_security_group_rule" "elasticache-ingress" {
  security_group_id = "${aws_security_group.elasticache.id}"
  type = "ingress"
  protocol = "tcp"
  from_port = 6379
  to_port = 6379
  source_security_group_id = "${aws_security_group.web-all.id}"
}

resource "aws_elasticache_cluster" "elasticache" {
  cluster_id = "nextcloud"
  engine = "redis"
  node_type = "${var.elasticache_node_type}"
  num_cache_nodes = 1
  parameter_group_name = "default.redis5.0"
  engine_version = "${var.elasticache_engine_version}"
  port = 6379
  subnet_group_name = "${aws_elasticache_subnet_group.elasticache.name}"
  security_group_ids = ["${aws_security_group.elasticache.id}"]
}

