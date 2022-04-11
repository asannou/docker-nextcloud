resource "aws_kms_key" "nextcloud" {
  enable_key_rotation = true
  tags = {
    Name = "nextcloud"
  }
}

resource "aws_kms_alias" "nextcloud" {
  name_prefix   = "alias/nextcloud-"
  target_key_id = aws_kms_key.nextcloud.key_id
  lifecycle {
    ignore_changes = [name_prefix]
  }
}

