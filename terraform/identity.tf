data "aws_iam_policy_document" "nextcloud" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "nextcloud" {
  name_prefix        = "EC2RoleNextcloud-"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.nextcloud.json
}

resource "aws_iam_instance_profile" "nextcloud" {
  name = aws_iam_role.nextcloud.name
  role = aws_iam_role.nextcloud.name
}

resource "aws_iam_role_policy_attachment" "nextcloud-ssm" {
  role       = aws_iam_role.nextcloud.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

