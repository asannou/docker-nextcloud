variable "aws_access_key" {}
variable "aws_secret_key" {}

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
#  default = "172.31.0.0/28"
}

variable "subnet_private" {
  default = [
#    "172.31.0.16/28",
#    "172.31.0.32/28",
  ]
}

variable "cidr_internal" {
#  default = "203.0.113.1/32"
}

variable "db_engine_version" {
  default = "5.6.29"
}

variable "db_instance_class" {
  default = "db.t2.micro"
}

variable "db_allocated_storage" {
  default = 10
}

variable "db_username" {}
variable "db_password" {}

variable "web_ami" {
  default = "ami-374db956"
}

variable "web_instance_type" {
  default = "t2.micro"
}

variable "web_volume_size" {
  default = 100
}

variable "web_key_name" {
#  default = "id_rsa"
}

variable "ssl_certificate_id" {
#  default = "arn:aws:iam::999999999999:server-certificate/nextcloud"
}

