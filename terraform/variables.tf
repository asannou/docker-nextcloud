variable "aws_region" {
  default = "ap-northeast-1"
}

variable "default_tags" {
  default = {
  }
}

variable "vpc_id" {
#  default = "vpc-deadbeef"
}

variable "gateway_id" {
#  default = "igw-deadbeef"
}

variable "subnet_public" {
  default = [
#    "172.31.0.0/28",
#    "172.31.0.48/28",
  ]
}

variable "subnet_private" {
  default = [
#    "172.31.0.16/28",
#    "172.31.0.32/28",
  ]
}

variable "cidr_internal" {
  default = [
#    "203.0.113.1/32"
  ]
}

variable "db_engine_version" {
  default = "8.0.23"
}

variable "db_parameter_group_name" {
  default = "default.mysql8.0"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  default = 10
}

variable "db_username" {
  default = ""
}

variable "db_password" {
  default = ""
}

variable "db_apply_immediately" {
  default = false
}

variable "elasticache_engine_version" {
  default = "6.x"
}

variable "elasticache_parameter_group_name" {
  default = "default.redis6.x"
}

variable "elasticache_node_type" {
  default = "cache.t3.micro"
}

variable "web_instance_type" {
  default = "t3.micro"
}

variable "web_instance_timezone" {
  default = "Asia/Tokyo"
}

variable "volume_size" {
  default = 100
}

variable "certificate_name" {
#  default = "nextcloud"
}

variable "certificate_id" {
  default = null
}

