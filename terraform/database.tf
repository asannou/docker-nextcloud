resource "aws_security_group" "db-mysql" {
  name_prefix = "nextcloud-db-mysql-"
  vpc_id      = var.vpc_id
  lifecycle {
    ignore_changes = [name_prefix]
  }
  tags = {
    Name = "nextcloud-db-mysql"
  }
}

resource "aws_security_group_rule" "db-mysql-ingress" {
  security_group_id        = aws_security_group.db-mysql.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.web-all.id
}

resource "aws_db_instance" "db" {
  identifier_prefix           = "nextcloud-"
  engine                      = "mysql"
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  allocated_storage           = var.db_allocated_storage
  storage_type                = "gp2"
  username                    = var.db_username
  password                    = var.db_password
  port                        = 3306
  multi_az                    = true
  db_subnet_group_name        = aws_db_subnet_group.db.name
  vpc_security_group_ids      = [aws_security_group.db-mysql.id]
  parameter_group_name        = var.db_parameter_group_name
  backup_retention_period     = 7
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  ca_cert_identifier          = "rds-ca-2019"
  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.nextcloud.arn
  skip_final_snapshot         = var.db_skip_final_snapshot
  apply_immediately           = var.db_apply_immediately
  lifecycle {
    ignore_changes = [
      identifier_prefix,
      username,
      password,
      snapshot_identifier
    ]
  }
  tags = {
    Name = "nextcloud-db"
  }
}

