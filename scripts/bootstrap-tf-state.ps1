# One-time bootstrap for Terraform remote state — PowerShell version
# Run: .\scripts\bootstrap-tf-state.ps1
$BUCKET = "secureship-tf-state-081382613682"
$TABLE = "secureship-tf-lock"
$REGION = "ap-south-1"
$PROFILE = "cloudsentry"

Write-Host "Creating S3 bucket: $BUCKET ($REGION)..."
try {
  aws s3api create-bucket --bucket $BUCKET --region $REGION --profile $PROFILE --create-bucket-configuration LocationConstraint=$REGION
} catch { Write-Host "Bucket may already exist, continuing..." }

aws s3api put-bucket-versioning --bucket $BUCKET --profile $PROFILE --versioning-configuration Status=Enabled
Write-Host "Versioning enabled."

Write-Host "Creating DynamoDB table: $TABLE..."
try {
  aws dynamodb create-table --table-name $TABLE --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region $REGION --profile $PROFILE
} catch { Write-Host "Table may already exist, continuing..." }

Write-Host "Done. Bucket: $BUCKET | Table: $TABLE | Region: $REGION"
