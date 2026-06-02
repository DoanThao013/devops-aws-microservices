output "default_sg_id" {
  description = "Default Security Group ID"
  value       = aws_default_security_group.default.id
}

output "public_sg_id" {
  description = "Public EC2 Security Group ID"
  value       = aws_security_group.public_ec2.id
}

output "private_sg_id" {
  description = "Private EC2 Security Group ID"
  value       = aws_security_group.private_ec2.id
}
