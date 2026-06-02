variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag (group/student name)"
  type        = string
  default     = "nt548-group-03"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "nt548"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for Public Subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for Private Subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "AZ for subnets"
  type        = string
  default     = "ap-southeast-1a"
}

variable "my_ip" {
  description = "Your public IP in CIDR format (e.g. 1.2.3.4/32) for SSH access to Public EC2"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name (must exist in AWS)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2). Leave empty to auto-detect latest."
  type        = string
  default     = ""
}
