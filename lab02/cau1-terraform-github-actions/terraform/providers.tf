terraform {
  required_version = ">= 1.5.0"
  
  backend "s3" {
    bucket = "nt548-terraform-state-23521551" 
    key    = "lab02/cau1/terraform.tfstate"
    region = "ap-southeast-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "NT548-Lab02" # Mình đổi nhẹ thành Lab02 cho chuẩn nhé
      ManagedBy   = "Terraform"
      Environment = var.environment
      Owner       = var.owner
    }
  }
}