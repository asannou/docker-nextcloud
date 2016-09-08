provider "aws" {
  region = "${var.aws_region}"
}

data "aws_caller_identity" "aws" {}

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
    cidr_block = "${var.cidr_internal}"
  }
  ingress {
    rule_no = 110
    action = "allow"
    protocol = "tcp"
    from_port = 8000
    to_port = 8000
    cidr_block = "${var.cidr_internal}"
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

resource "aws_security_group" "elb-internal" {
  name = "nextcloud-elb-internal"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "nextcloud-elb-internal"
  }
}

resource "aws_security_group_rule" "elb-internal-ingress" {
  security_group_id = "${aws_security_group.elb-internal.id}"
  type = "ingress"
  protocol = "tcp"
  from_port = 8000
  to_port = 8000
  cidr_blocks = ["${var.cidr_internal}"]
}

resource "aws_security_group_rule" "elb-internal-egress" {
  security_group_id = "${aws_security_group.elb-internal.id}"
  type = "egress"
  protocol = "tcp"
  from_port = 8000
  to_port = 8000
  source_security_group_id = "${aws_security_group.web-internal.id}"
}

resource "aws_security_group" "elb-external" {
  name = "nextcloud-elb-external"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "nextcloud-elb-external"
  }
}

resource "aws_security_group_rule" "elb-external-ingress" {
  security_group_id = "${aws_security_group.elb-external.id}"
  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb-external-egress" {
  security_group_id = "${aws_security_group.elb-external.id}"
  type = "egress"
  protocol = "tcp"
  from_port = 80
  to_port = 80
  source_security_group_id = "${aws_security_group.web-external.id}"
}

resource "aws_security_group" "web-internal" {
  name = "nextcloud-web-internal"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "nextcloud-web-internal"
  }
}

resource "aws_security_group_rule" "web-internal-ingress" {
  security_group_id = "${aws_security_group.web-internal.id}"
  type = "ingress"
  protocol = "tcp"
  from_port = 8000
  to_port = 8000
  source_security_group_id = "${aws_security_group.elb-internal.id}"
}

resource "aws_security_group" "web-external" {
  name = "nextcloud-web-external"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "nextcloud-web-external"
  }
}

resource "aws_security_group_rule" "web-external-ingress" {
  security_group_id = "${aws_security_group.web-external.id}"
  type = "ingress"
  protocol = "tcp"
  from_port = 80
  to_port = 80
  source_security_group_id = "${aws_security_group.elb-external.id}"
}

resource "aws_security_group" "web-ssh" {
  name = "nextcloud-web-ssh"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "nextcloud-web-ssh"
  }
}

resource "aws_security_group_rule" "web-ssh-ingress" {
  security_group_id = "${aws_security_group.web-ssh.id}"
  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = ["${var.cidr_internal}"]
}

resource "aws_security_group" "web-all" {
  name = "nextcloud-web-all"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "nextcloud-web-all"
  }
}

resource "aws_security_group_rule" "web-all-egress" {
  security_group_id = "${aws_security_group.web-all.id}"
  type = "egress"
  protocol = "all"
  from_port = 0
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "db-mysql" {
  name = "nextcloud-db-mysql"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "nextcloud-db-mysql"
  }
}

resource "aws_security_group_rule" "db-mysql-ingress" {
  security_group_id = "${aws_security_group.db-mysql.id}"
  type = "ingress"
  protocol = "tcp"
  from_port = 3306
  to_port = 3306
  source_security_group_id = "${aws_security_group.web-all.id}"
}

resource "aws_db_instance" "db" {
  identifier = "nextcloud"
  engine = "mysql"
  engine_version = "${var.db_engine_version}"
  instance_class = "${var.db_instance_class}"
  allocated_storage = "${var.db_allocated_storage}"
  username = "${var.db_username}"
  password = "${var.db_password}"
  port = 3306
  multi_az = true
  db_subnet_group_name = "${aws_db_subnet_group.db.name}"
  vpc_security_group_ids = ["${aws_security_group.db-mysql.id}"]
  parameter_group_name = "default.mysql5.6"
  backup_retention_period = 7
  auto_minor_version_upgrade = true
  tags {
    Name = "nextcloud-db"
  }
}

resource "aws_instance" "web" {
  ami = "${var.web_ami}"
  instance_type = "${var.web_instance_type}"
  subnet_id = "${aws_subnet.public.id}"
  associate_public_ip_address = true
  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }
  key_name = "${var.web_key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.web-all.id}",
    "${aws_security_group.web-ssh.id}",
    "${aws_security_group.web-internal.id}",
    "${aws_security_group.web-external.id}",
  ]
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
    }
    inline = [
      "sudo yum -y update",
      "sudo yum -y install git docker",
    ]
  }
  tags {
    Name = "nextcloud-web"
  }
}

resource "aws_ebs_volume" "volume" {
  availability_zone = "${aws_subnet.public.availability_zone}"
  type = "gp2"
  size = "${var.volume_size}"
  tags {
    Name = "nextcloud"
  }
}

resource "aws_volume_attachment" "volume_attachment" {
  volume_id = "${aws_ebs_volume.volume.id}"
  instance_id = "${aws_instance.web.id}"
  device_name = "/dev/xvdh"
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = "${aws_instance.web.public_ip}"
    }
    inline = [
      "sudo mkdir /volume",
      "sudo mount /dev/xvdh /volume || sudo mkfs -t ext4 /dev/xvdh",
      "echo '/dev/xvdh /volume ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
      "sudo service docker start",
      "sudo chkconfig docker on",
      "sudo docker run -d --name nextcloud -v /volume:/volume asannou/nextcloud:strict",
      "sudo docker run -d --cap-add=NET_ADMIN --name nextcloud-proxy -p 8000:8000 -p 80:80 --link nextcloud asannou/nextcloud-sharing-only-proxy:strict",
    ]
  }
}

resource "aws_elb" "elb" {
  name = "nextcloud"
  subnets = ["${aws_subnet.public.id}"]
  instances = ["${aws_instance.web.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 60
  listener {
    lb_port = 8000
    lb_protocol = "https"
    instance_port = 8000
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::${data.aws_caller_identity.aws.account_id}:server-certificate/${var.server_certificate_name}"
  }
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 80
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::${data.aws_caller_identity.aws.account_id}:server-certificate/${var.server_certificate_name}"
  }
  security_groups = [
    "${aws_security_group.elb-internal.id}",
    "${aws_security_group.elb-external.id}",
  ]
  health_check {
    target = "TCP:8000"
    interval = 30
    timeout = 5
    unhealthy_threshold = 2
    healthy_threshold = 2
  }
  tags {
    Name = "nextcloud-elb"
  }
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "nextcloud-terraform-state.${data.aws_caller_identity.aws.account_id}"
  acl = "private"
  tags {
    Name = "nextcloud-terraform-state"
  }
}

