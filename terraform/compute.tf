resource "aws_security_group" "elb-internal" {
  name   = "nextcloud-elb-internal"
  vpc_id = var.vpc_id
  tags = {
    Name = "nextcloud-elb-internal"
  }
}

resource "aws_security_group_rule" "elb-internal-ingress" {
  security_group_id = aws_security_group.elb-internal.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8000
  to_port           = 8000
  cidr_blocks       = var.cidr_internal
}

resource "aws_security_group_rule" "elb-internal-egress" {
  security_group_id        = aws_security_group.elb-internal.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8000
  to_port                  = 8000
  source_security_group_id = aws_security_group.web-internal.id
}

resource "aws_security_group" "elb-external" {
  name   = "nextcloud-elb-external"
  vpc_id = var.vpc_id
  tags = {
    Name = "nextcloud-elb-external"
  }
}

resource "aws_security_group_rule" "elb-external-ingress" {
  security_group_id = aws_security_group.elb-external.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb-external-egress" {
  security_group_id        = aws_security_group.elb-external.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.web-external.id
}

resource "aws_security_group" "web-internal" {
  name   = "nextcloud-web-internal"
  vpc_id = var.vpc_id
  tags = {
    Name = "nextcloud-web-internal"
  }
}

resource "aws_security_group_rule" "web-internal-ingress" {
  security_group_id        = aws_security_group.web-internal.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8000
  to_port                  = 8000
  source_security_group_id = aws_security_group.elb-internal.id
}

resource "aws_security_group" "web-external" {
  name   = "nextcloud-web-external"
  vpc_id = var.vpc_id
  tags = {
    Name = "nextcloud-web-external"
  }
}

resource "aws_security_group_rule" "web-external-ingress" {
  security_group_id        = aws_security_group.web-external.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.elb-external.id
}

resource "aws_security_group" "web-all" {
  name   = "nextcloud-web-all"
  vpc_id = var.vpc_id
  tags = {
    Name = "nextcloud-web-all"
  }
}

resource "aws_security_group_rule" "web-all-egress" {
  security_group_id = aws_security_group.web-all.id
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

data "template_cloudinit_config" "user_data" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.user_data.rendered
  }
}

data "template_file" "user_data" {
  template = file("user_data.tpl.yml")
  vars = {
    yum-cron-security_conf = base64encode(file("user_data/yum-cron-security.conf"))
    yum-security_cron      = base64encode(file("user_data/yum-security.cron"))
    post-yum-security_cron = base64encode(file("user_data/post-yum-security.cron"))
    docker-nextcloud       = base64encode(file("user_data/docker-nextcloud"))
    docker-nextcloud_cron  = base64encode(file("user_data/docker-nextcloud.cron"))
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ami.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public0.id
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }
  vpc_security_group_ids = [
    aws_security_group.web-all.id,
    aws_security_group.web-internal.id,
    aws_security_group.web-external.id,
  ]
  user_data_base64     = data.template_cloudinit_config.user_data.rendered
  iam_instance_profile = aws_iam_instance_profile.nextcloud.name
  lifecycle {
    ignore_changes = [
      ami,
      user_data_base64,
    ]
  }
  tags = {
    Name = "nextcloud-web"
  }
}

resource "aws_ebs_volume" "volume" {
  availability_zone = aws_subnet.public0.availability_zone
  type              = "gp2"
  size              = var.volume_size
  tags = {
    Name = "nextcloud"
  }
}

resource "aws_volume_attachment" "volume_attachment" {
  volume_id    = aws_ebs_volume.volume.id
  instance_id  = aws_instance.web.id
  device_name  = "/dev/xvdh"
  skip_destroy = true
}

resource "aws_lb" "alb" {
  name               = "nextcloud"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.elb-internal.id,
    aws_security_group.elb-external.id,
  ]
  subnets = [
    aws_subnet.public0.id,
    aws_subnet.public1.id,
  ]
  idle_timeout         = 3600
  enable_http2         = false
  enable_waf_fail_open = true
  tags = {
    Name = "nextcloud-alb"
  }
}

resource "aws_lb_listener" "alb-internal" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "8000"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-internal.arn
  }
}

resource "aws_lb_target_group" "alb-internal" {
  name     = "nextcloud-internal"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
    path                = "/status.php"
    matcher             = "400"
  }
}

resource "aws_lb_target_group_attachment" "alb-internal" {
  target_group_arn = aws_lb_target_group.alb-internal.arn
  target_id        = aws_instance.web.id
  port             = 8000
}

resource "aws_lb_listener" "alb-external" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-external.arn
  }
}

resource "aws_lb_target_group" "alb-external" {
  name     = "nextcloud-external"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
    matcher             = "400"
  }
}

resource "aws_lb_target_group_attachment" "alb-external" {
  target_group_arn = aws_lb_target_group.alb-external.arn
  target_id        = aws_instance.web.id
  port             = 80
}

