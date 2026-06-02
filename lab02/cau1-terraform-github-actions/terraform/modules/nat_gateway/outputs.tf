output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "nat_eip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}
