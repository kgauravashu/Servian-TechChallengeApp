#############################################
# Configure the AWS Provider
#############################################
provider "aws" {
  region = "ap-southeast-2"
}

# configure terraform version and backend s3 for terraform state file
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.59.0"
    }
  }

  backend "s3" {
    bucket = "gaurav-terraform-s3"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
  }
}

