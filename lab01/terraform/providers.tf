terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment after creating S3 bucket nt548-tfstate-<groupID>
  # backend "s3" {
  #   bucket         = "nt548-tfstate-<groupID>"
  #   key            = "lab01/terraform.tfstate"
  #   region         = "ap-southeast-1"
  #   dynamodb_table = "nt548-tflock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "NT548-Lab01"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Owner       = var.owner
    }
  }
}
