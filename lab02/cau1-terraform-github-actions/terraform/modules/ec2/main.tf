# ─── Public EC2 Instance ──────────────────────────────────────────────────────
resource "aws_instance" "public" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.public_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Bắt buộc IMDSv2 _ CKV_AWS_79
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "${var.name_prefix}-public-ec2"
    Role = "Public"
  }
}

# ─── Private EC2 Instance ─────────────────────────────────────────────────────
resource "aws_instance" "private" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.private_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Bắt buộc IMDSv2 _ CKV_AWS_79
    http_put_response_hop_limit = 1
  }
  
  tags = {
    Name = "${var.name_prefix}-private-ec2"
    Role = "Private"
  }
}
