data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = min(
    length(var.subnet_public_netnum),
    length(data.aws_availability_zones.available.names)
  )
  vpc_id = var.vpc_id
  cidr_block = cidrsubnet(
    var.subnet_prefix,
    var.subnet_newbits,
    var.subnet_public_netnum[count.index]
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]
  lifecycle {
    ignore_changes = [
      availability_zone,
    ]
  }
  tags = {
    Name = "nextcloud-public${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = min(
    length(var.subnet_private_netnum),
    length(data.aws_availability_zones.available.names)
  )
  vpc_id = var.vpc_id
  cidr_block = cidrsubnet(
    var.subnet_prefix,
    var.subnet_newbits,
    var.subnet_private_netnum[count.index]
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]
  lifecycle {
    ignore_changes = [
      availability_zone,
    ]
  }
  tags = {
    Name = "nextcloud-private${count.index}"
  }
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }
  tags = {
    Name = "nextcloud-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags = {
    Name = "nextcloud-private"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_db_subnet_group" "db" {
  name_prefix = "nextcloud-"
  subnet_ids  = [for subnet in aws_subnet.private : subnet.id]
  lifecycle {
    ignore_changes = [name_prefix]
  }
  tags = {
    Name = "nextcloud-private"
  }
}

resource "aws_network_acl" "acl-public" {
  vpc_id     = var.vpc_id
  subnet_ids = [for subnet in aws_subnet.public : subnet.id]
  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 8000
    to_port    = 8000
    cidr_block = "0.0.0.0/0"
  }
  ingress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }
  ingress {
    rule_no    = 130
    action     = "allow"
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
  }
  ingress {
    rule_no    = 140
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "all"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "nextcloud-acl-public"
  }
}

resource "aws_network_acl" "acl-private" {
  vpc_id     = var.vpc_id
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 3306
    to_port    = 3306
    cidr_block = aws_subnet.public[0].cidr_block
  }
  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 6379
    to_port    = 6379
    cidr_block = aws_subnet.public[0].cidr_block
  }
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = aws_subnet.public[0].cidr_block
  }
  tags = {
    Name = "nextcloud-acl-private"
  }
}

