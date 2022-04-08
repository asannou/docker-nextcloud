variable "aws_region" {
  default = "ap-northeast-1"
}

variable "default_tags" {
  default = {
  }
}

variable "vpc_id" {
  #default = "vpc-deadbeef"
}

variable "subnet_prefix" {
  #default = "172.31.0.0/24"
}

variable "subnet_newbits" {
  default = 4
}

variable "subnet_public_netnum" {
  default = [0, 3]
}

variable "subnet_private_netnum" {
  default = [1, 2]
}

variable "cidr_internal" {
  default = [
    #"203.0.113.1/32"
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
  type = string
}

variable "db_password" {
  type = string
}

variable "db_skip_final_snapshot" {
  default = false
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
  #default = "nextcloud"
}

variable "certificate_id" {
  default = null
}

variable "s3_bucket_force_destroy" {
  default = false
}

