locals {
  certificate_arn = (
    var.certificate_name != null ? "arn:aws:iam::${data.aws_caller_identity.aws.account_id}:server-certificate/${var.certificate_name}" :
    var.certificate_id != null ? "arn:aws:acm:${var.aws_region}:${data.aws_caller_identity.aws.account_id}:certificate/${var.certificate_id}" :
    null
  )
}

