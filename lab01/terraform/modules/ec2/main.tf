# ─── Public EC2 Instance ──────────────────────────────────────────────────────
resource "aws_instance" "public" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.public_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

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

  tags = {
    Name = "${var.name_prefix}-private-ec2"
    Role = "Private"
  }
}
