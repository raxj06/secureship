provider "aws" {
  region  = var.region
  profile = "cloudsentry"
}

# Remote state backend — S3 + DynamoDB (created via scripts/bootstrap-tf-state.sh)
terraform {
  backend "s3" {
    bucket         = "secureship-tf-state-081382613682"
    key            = "foundation/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "secureship-tf-lock"
    encrypt        = true
    profile        = "cloudsentry"
  }
}
