terraform {
  required_version = ">= 1.5"

  backend "s3" {
    bucket         = "secureship-tf-state-081382613682"
    key            = "cluster/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "secureship-tf-lock"
    profile        = "cloudsentry"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
