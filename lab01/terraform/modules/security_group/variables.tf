variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "my_ip" {
  description = "Your public IP in CIDR format (e.g. 1.2.3.4/32)"
  type        = string
}
