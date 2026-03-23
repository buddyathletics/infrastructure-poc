terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "buddy-athletics-terraform-state-bucket"
    key            = "networking/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "buddy-athletics-terraform-locks"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "buddy-athletics"
}
