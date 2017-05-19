resource "aws_subnet" "public" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.subnet_public}"
  availability_zone = "${var.aws_region}a"
  tags {
    Name = "nextcloud-public"
  }
}

resource "aws_subnet" "private0" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.subnet_private[0]}"
  availability_zone = "${var.aws_region}a"
  tags {
    Name = "nextcloud-private0"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.subnet_private[1]}"
  availability_zone = "${var.aws_region}c"
  tags {
    Name = "nextcloud-private1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.gateway_id}"
  }
  tags {
    Name = "nextcloud-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "nextcloud-private"
  }
}

resource "aws_route_table_association" "private0" {
  subnet_id = "${aws_subnet.private0.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private1" {
  subnet_id = "${aws_subnet.private1.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_db_subnet_group" "db" {
  name = "nextcloud"
  subnet_ids = [
    "${aws_subnet.private0.id}",
    "${aws_subnet.private1.id}",
  ]
  tags {
    Name = "nextcloud-private"
  }
}

resource "aws_network_acl" "acl-public" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.public.id}"]
  ingress {
    rule_no = 100
    action = "allow"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_block =  "0.0.0.0/0"
  }
  ingress {
    rule_no = 110
    action = "allow"
    protocol = "tcp"
    from_port = 8000
    to_port = 8000
    cidr_block =  "0.0.0.0/0"
  }
  ingress {
    rule_no = 120
    action = "allow"
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_block =  "0.0.0.0/0"
  }
  ingress {
    rule_no = 130
    action = "allow"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_block =  "0.0.0.0/0"
  }
  ingress {
    rule_no = 140
    action = "allow"
    protocol = "tcp"
    from_port = 1024
    to_port = 65535
    cidr_block =  "0.0.0.0/0"
  }
  egress {
    rule_no = 100
    action = "allow"
    protocol = "all"
    from_port = 0
    to_port = 0
    cidr_block =  "0.0.0.0/0"
  }
  tags {
      Name = "nextcloud-acl-public"
  }
}

resource "aws_network_acl" "acl-private" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = [
    "${aws_subnet.private0.id}",
    "${aws_subnet.private1.id}",
  ]
  ingress {
    rule_no = 100
    action = "allow"
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
    cidr_block =  "${var.subnet_public}"
  }
  egress {
    rule_no = 100
    action = "allow"
    protocol = "tcp"
    from_port = 1024
    to_port = 65535
    cidr_block =  "${var.subnet_public}"
  }
  tags {
      Name = "nextcloud-acl-private"
  }
}

