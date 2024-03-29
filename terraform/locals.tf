locals {
  certificate_arn = (
    var.certificate_name != null ? "arn:aws:iam::${data.aws_caller_identity.aws.account_id}:server-certificate/${var.certificate_name}" :
    var.certificate_id != null ? "arn:aws:acm:${data.aws_region.aws.name}:${data.aws_caller_identity.aws.account_id}:certificate/${var.certificate_id}" :
    null
  )
}

data "aws_region" "aws" {}

data "aws_caller_identity" "aws" {}

resource "random_id" "nextcloud" {
  byte_length = 8
}

