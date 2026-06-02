variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID where NAT Gateway will be placed"
  type        = string
}
