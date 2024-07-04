
provider "aws" {
  profile = var.profile
  region  = var.region
}


terraform {
  backend "s3" {
    bucket  = "gms-terraform-state-dev"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "personal"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.56.1"
    }
  }
}

