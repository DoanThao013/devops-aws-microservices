resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# <--- CKV2_AWS_12
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  # Bỏ trống không cấu hình ingress/egress = Khóa mọi kết nối
}