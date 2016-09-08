output "aws.account_id" {
  value = "${data.aws_caller_identity.aws.account_id}"
}

output "web.public_ip" {
  value = "${aws_instance.web.public_ip}"
}

output "elb.dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

output "db.endpoint" {
  value = "${aws_db_instance.db.endpoint}"
}

output "tfstate.bucket" {
  value = "${aws_s3_bucket.tfstate.bucket}"
}

