variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for Public Subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for Private Subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
}
