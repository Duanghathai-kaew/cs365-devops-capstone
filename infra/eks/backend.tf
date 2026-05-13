terraform {
  required_version = "~> 1.9.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
    backend "s3" {
      bucket         = "cs365-terraform-state-kaew"
      key            = "eks/terraform.tfstate"
      region         = "us-east-1"
      dynamodb_table = "terraform-lock"
      encrypt        = true
    }
}

provider "aws" {
  region = var.aws_region
}
