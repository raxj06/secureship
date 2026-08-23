#!/bin/bash
# One-time bootstrap for Terraform remote state backend
# Creates S3 bucket + DynamoDB table for foundation state
# Usage: bash scripts/bootstrap-tf-state.sh
#   or:  ./scripts/bootstrap-tf-state.sh (git bash / WSL)
# Windows PowerShell alternative: run the 3 aws commands manually with --profile cloudsentry
set -e

BUCKET="secureship-tf-state-081382613682"
TABLE="secureship-tf-lock"
REGION="ap-south-1"
PROFILE="cloudsentry"

echo "Creating S3 bucket: $BUCKET ($REGION)..."
aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --create-bucket-configuration LocationConstraint="$REGION" 2>&1 || echo "Bucket may already exist, continuing..."

echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --profile "$PROFILE" \
  --versioning-configuration Status=Enabled

echo "Creating DynamoDB table: $TABLE..."
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" \
  --profile "$PROFILE" 2>&1 || echo "Table may already exist, continuing..."

echo "Done."
echo "  Bucket: $BUCKET"
echo "  Table:  $TABLE"
echo "  Region: $REGION"
