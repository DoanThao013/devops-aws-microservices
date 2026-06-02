output "public_ec2_id" {
  description = "Public EC2 Instance ID"
  value       = aws_instance.public.id
}

output "public_ec2_public_ip" {
  description = "Public IP of Public EC2"
  value       = aws_instance.public.public_ip
}

output "public_ec2_private_ip" {
  description = "Private IP of Public EC2"
  value       = aws_instance.public.private_ip
}

output "private_ec2_id" {
  description = "Private EC2 Instance ID"
  value       = aws_instance.private.id
}

output "private_ec2_private_ip" {
  description = "Private IP of Private EC2"
  value       = aws_instance.private.private_ip
}
