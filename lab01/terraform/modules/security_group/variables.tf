variable "name_prefix" {
  type    = string
  default = "nt548"
}

variable "vpc_id" {
  type = string
}

variable "my_ip" {
  type        = string
  description = "Your public IP in CIDR format"
}
