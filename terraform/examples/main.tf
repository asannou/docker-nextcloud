module "nextcloud" {
  source        = "github.com/asannou/docker-nextcloud//terraform"
  vpc_id        = "vpc-deadbeef"
  subnet_prefix = "172.31.0.0/24"
  cidr_internal = [
    "203.0.113.1/32",
  ]
  db_username = var.db_username
  db_password = var.db_password
}

