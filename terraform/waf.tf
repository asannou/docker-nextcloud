resource "aws_wafv2_web_acl" "nextcloud" {
  name  = "nextcloud"
  scope = "REGIONAL"
  default_action {
    allow {}
  }
  rule {
    name     = "AmazonIpReputationList"
    priority = 0
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AnonymousIpList"
    priority = 1
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AnonymousIpList"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "CommonRuleSet"
    priority = 2
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "KnownBadInputsRuleSet"
    priority = 3
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "SQLiRuleSet"
    priority = 4
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "LinuxRuleSet"
    priority = 5
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "UnixRuleSet"
    priority = 6
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "UnixRuleSet"
      sampled_requests_enabled   = true
    }
  }
  tags = {
    Name = "nextcloud-waf"
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "nextcloud"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "nextcloud" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.nextcloud.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "nextcloud" {
  resource_arn            = aws_wafv2_web_acl.nextcloud.arn
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logging.arn]
}

resource "aws_kinesis_firehose_delivery_stream" "waf_logging" {
  name        = "aws-waf-logs-nextcloud"
  destination = "s3"
  s3_configuration {
    bucket_arn         = aws_s3_bucket.waf_logging.arn
    role_arn           = aws_iam_role.waf_logging.arn
    compression_format = "GZIP"
  }
  tags = {
    Name = "nextcloud-waf"
  }
}

resource "aws_s3_bucket" "waf_logging" {
  bucket_prefix = "nextcloud-waf-logs-"
  force_destroy = var.s3_bucket_force_destroy
  tags = {
    Name = "nextcloud-waf"
  }
}

resource "aws_s3_bucket_public_access_block" "waf_logging" {
  bucket                  = aws_s3_bucket.waf_logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logging" {
  bucket = aws_s3_bucket.waf_logging.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.nextcloud.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_iam_role" "waf_logging" {
  name               = "FirehoseRoleNextcloud"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.waf_logging.json
}

data "aws_iam_policy_document" "waf_logging" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "waf_logging" {
  role   = aws_iam_role.waf_logging.name
  policy = data.aws_iam_policy_document.waf_logging_policy.json
}

data "aws_iam_policy_document" "waf_logging_policy" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.waf_logging.arn,
      "${aws_s3_bucket.waf_logging.arn}/*",
    ]
  }
}

