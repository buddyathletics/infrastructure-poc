terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  backend "s3" {
    bucket = "buddy-athletics-terraform-state-bucket"
    key    = "infrastructure-poc/terraform.tfstate"
    region = "us-east-1"
    profile = "buddy-athletics"
  }
}

provider "aws" {
  region  = var.aws_region
}