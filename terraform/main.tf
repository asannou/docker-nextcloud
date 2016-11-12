provider "aws" {
  region = "${var.aws_region}"
}

data "aws_caller_identity" "aws" {}

resource "aws_s3_bucket" "tfstate" {
  bucket = "nextcloud-terraform-state.${data.aws_caller_identity.aws.account_id}"
  acl = "private"
  tags {
    Name = "nextcloud-terraform-state"
  }
}

