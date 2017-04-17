terraform {
  backend "s3" {
#    bucket = "nextcloud-terraform-state.123456789012"
    key    = "terraform.tfstate"
#    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

data "aws_caller_identity" "aws" {}

