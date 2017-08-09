resource "aws_iam_role" "nextcloud" {
  name = "EC2RoleNextcloud"
  path = "/"
  assume_role_policy = <<EOD
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOD
}

resource "aws_iam_instance_profile" "nextcloud" {
  name = "${aws_iam_role.nextcloud.name}"
  role = "${aws_iam_role.nextcloud.name}"
}

resource "aws_iam_role_policy_attachment" "nextcloud-ssm" {
  role = "${aws_iam_role.nextcloud.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

