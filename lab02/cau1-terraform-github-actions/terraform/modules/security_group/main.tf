# ─── Default VPC Security Group ───────────────────────────────────────────────
resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-default-sg"
  }
}

# ─── Public EC2 Security Group ────────────────────────────────────────────────
resource "aws_security_group" "public_ec2" {
  name        = "${var.name_prefix}-public-ec2-sg"
  description = "Allow SSH from my IP only"
  vpc_id      = var.vpc_id

  # SSH from specific IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Allow HTTPS for curl
  egress {
    description = "Allow HTTPS for curl"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow DNS resolution
  egress {
    description = "Allow DNS resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-public-ec2-sg"
  }
}

# ─── Private EC2 Security Group ───────────────────────────────────────────────
resource "aws_security_group" "private_ec2" {
  name        = "${var.name_prefix}-private-ec2-sg"
  description = "Allow SSH from Public EC2 SG only"
  vpc_id      = var.vpc_id

  # SSH only from Public EC2 Security Group
  ingress {
    description     = "SSH from Public EC2 SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2.id]
  }

  # Allow HTTPS for curl
  egress {
    description = "Allow HTTPS for curl"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow DNS resolution
  egress {
    description = "Allow DNS resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-private-ec2-sg"
  }
}