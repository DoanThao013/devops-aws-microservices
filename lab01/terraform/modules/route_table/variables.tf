variable "name_prefix" {
  type    = string
  default = "nt548"
}

variable "vpc_id" {
  type = string
}

variable "internet_gateway_id" {
  type = string
}

variable "nat_gateway_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}
