variable "aws_region" {
  default = "ap-northeast-1"
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
  default = "5.7.30"
}

variable "db_parameter_group_name" {
  default = "default.mysql5.7"
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

variable "elasticache_engine_version" {
  default = "5.0.4"
}

variable "elasticache_node_type" {
  default = "cache.t2.micro"
}

variable "key_file_name" {
  default = "id_nextcloud"
}

variable "web_instance_type" {
  default = "t2.micro"
}

variable "web_instance_timezone" {
  default = "Asia/Tokyo"
}

variable "volume_size" {
  default = 100
}

variable "server_certificate_name" {
#  default = "nextcloud"
}

