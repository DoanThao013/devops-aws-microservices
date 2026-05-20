output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = module.subnet.public_subnet_id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = module.subnet.private_subnet_id
}

output "public_ec2_public_ip" {
  description = "Public IP of Public EC2 instance"
  value       = module.ec2.public_ec2_public_ip
}

output "private_ec2_private_ip" {
  description = "Private IP of Private EC2 instance"
  value       = module.ec2.private_ec2_private_ip
}

output "ssh_command" {
  description = "Command to SSH into Public EC2"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${module.ec2.public_ec2_public_ip}"
}
