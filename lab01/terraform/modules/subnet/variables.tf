variable "name_prefix" {
  type    = string
  default = "nt548"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "availability_zone" {
  type = string
}
