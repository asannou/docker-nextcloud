output "aws.account_id" {
  value = "${data.aws_caller_identity.aws.account_id}"
}

output "web.public_ip" {
  value = "${aws_instance.web.public_ip}"
}

output "alb.dns_name" {
  value = "${aws_lb.alb.dns_name}"
}

output "db.endpoint" {
  value = "${aws_db_instance.db.endpoint}"
}

output "elasticache.endpoint" {
  value = "${aws_elasticache_replication_group.elasticache.primary_endpoint_address}:${aws_elasticache_replication_group.elasticache.port}"
}

